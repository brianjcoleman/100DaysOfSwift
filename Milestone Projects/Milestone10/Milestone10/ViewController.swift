//
//  ViewController.swift
//  Milestone10
//
//  Created by Brian Coleman on 2022-06-02.
//

import UIKit

class ViewController: UICollectionViewController {
    var cards = [Card]()
    var flippedCards = [(position: Int, card: Card)]()
    var backImageSize: CGSize!
    var cardSize: CardSize!
    var currentCardSizeValid = false
    var currentCardSize: CGSize!
    
    var flipAnimator = FlipCardAnimator()
    var matchedCardsAnimators = [MatchedCardsAnimator]()
    var unmatchedCardsAnimator = UnmatchedCardsAnimator()

    var gridSide1 = 4
    var gridSide2 = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Match Pairs"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Game", style: .plain, target: self, action: #selector(newGame))

        cardSize = CardSize(imageSize: CGSize(width: 50, height: 50), gridSide1: gridSide1, gridSide2: gridSide2)
        
        newGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCardSize()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        updateCardSize()
    }

    @objc func newGame() {
        guard (gridSide1 * gridSide2) % 2 == 0 else { return }
        
        cardSize.gridSide1 = gridSide1
        cardSize.gridSide2 = gridSide2

        cards = [Card]()
        resetFlippedCards()
        cancelAnimators()
        
        loadCards()

        currentCardSizeValid = false
        collectionView.reloadData()
    }
    
    func loadCards() {
        let backImage: String = "0"
        var frontImages = [String]()
               
        for i in 1 ... 12 {
            frontImages.append("\(i)")
        }
        
        guard let size = UIImage(named: backImage)?.size else { return }
        cardSize.imageSize = size

        let cardsNumber = gridSide1 * gridSide2
        
        while frontImages.count > cardsNumber / 2 {
            frontImages.remove(at: Int.random(in: 0..<frontImages.count))
        }

        while frontImages.count < cardsNumber / 2 {
            frontImages.append(frontImages[Int.random(in: 0..<frontImages.count)])
        }
        
        frontImages += frontImages
        frontImages.shuffle()

        for i in 0..<cardsNumber {
            cards.append(Card(frontImage: frontImages[i], backImage: backImage))
        }
    }
    
    func matchCards() {
        guard let (oldCard, oldCell) = getFlippedCard(at: 0) else { return }
        guard let (newCard, newCell) = getFlippedCard(at: 1) else { return }

        oldCard.state = .matched
        newCard.state = .matched

        let animator = MatchedCardsAnimator()
        matchedCardsAnimators.append(animator)

        animator.start(oldCell: oldCell, newCell: newCell) { [weak self] in
            self?.matchedCardsAnimators.removeAll(where: { $0 === animator })
            self?.checkCompletion()
        }

        flippedCards.removeAll(keepingCapacity: true)
    }
    
    func checkCompletion() {
        guard matchedCardsAnimators.isEmpty else { return }

        for card in cards {
            if card.state != .matched && card.state != .complete {
                return
            }
        }
        
        for card in cards {
            card.state = .complete
        }

        let ac = UIAlertController(title: "You Win!", message: "Would you like to play again?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
            self?.newGame()
        }))
        present(ac, animated: true)
    }

    func unmatchCards() {
        guard let (oldCard, oldCell) = getFlippedCard(at: 0) else { return }
        guard let (newCard, newCell) = getFlippedCard(at: 1) else { return }

        oldCard.state = .back
        newCard.state = .back

        unmatchedCardsAnimator.start(oldCell: oldCell, newCell: newCell) { [weak self] in
            self?.resetFlippedCards()
        }
    }

    func forceFinishUnmatchCards() {
        guard let (_, oldCell) = getFlippedCard(at: 0) else { return }
        guard let (_, newCell) = getFlippedCard(at: 1) else { return }

        unmatchedCardsAnimator.forceFlipToBack(oldCell: oldCell, newCell: newCell)

        resetFlippedCards()
    }

    func getFlippedCard(at index: Int) -> (Card, CardCell)? {
        let (position, card) = flippedCards[index]

        let indexPath = IndexPath(item: position, section: 0)

        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else {
            return nil
        }

        return (card, cell)
    }
    
    func resetFlippedCards() {
        flippedCards.removeAll(keepingCapacity: true)
    }

    func cancelAnimators() {
        flipAnimator.cancel()
        unmatchedCardsAnimator.cancel()
        for animator in matchedCardsAnimators {
            animator.cancel()
        }
        matchedCardsAnimators.removeAll()
    }
    
    private func updateCardSize() {
        currentCardSizeValid = false
        collectionView?.collectionViewLayout.invalidateLayout()

        for cell in collectionView.visibleCells {
            if let cell = cell as? CardCell {
                cell.updateAfterRotateOrResize()
            }
        }
    }
}

// MARK:- UICollectionViewDataSource

extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)

        guard let cell = dequeuedCell as? CardCell else { return dequeuedCell }

        cell.set(card: cards[indexPath.row])

        return cell
    }
}



// MARK:- UICollectionViewDelegate

extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else { return }

        guard cards[indexPath.row].state == .back else { return }

        cards[indexPath.row].state = .front

        if flippedCards.count == 0 {
            flipAnimator.flipTo(state: .front, cell: cell)
            flippedCards.append((position: indexPath.row, card: cards[indexPath.row]))
            return
        }

        if flippedCards.count == 1 {
            flippedCards.append((position: indexPath.row, card: cards[indexPath.row]))

            if flippedCards[0].card.frontImage == flippedCards[1].card.frontImage {
                matchCards()
            } else {
                unmatchCards()
            }
            return
        }

        if flippedCards.count == 2 {
            if indexPath.row == flippedCards[0].position || indexPath.row == flippedCards[1].position {
                cards[indexPath.row].state = .back
                forceFinishUnmatchCards()
                return
            }

            forceFinishUnmatchCards()
            flipAnimator.flipTo(state: .front, cell: cell)
            flippedCards.append((position: indexPath.row, card: cards[indexPath.row]))
            return
        }
    }
}

// MARK:- UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if currentCardSizeValid {
            return currentCardSize
        }

        currentCardSize = cardSize.getCardSize(collectionView: collectionView)
        currentCardSizeValid = true
        return currentCardSize
    }
}
