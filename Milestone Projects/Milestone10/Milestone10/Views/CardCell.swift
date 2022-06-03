//
//  CardCell.swift
//  Milestone10
//
//  Created by Brian Coleman on 2022-06-02.
//

import UIKit

class CardCell: UICollectionViewCell {
    var front: UIImageView!
    var back: UIImageView!
    var card: Card?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }

    func set(card: Card) {
        self.card = card
        front.image = UIImage(named: card.frontImage)
        back.image = UIImage(named: card.backImage)

        reset(state: card.state)
    }

    func animateFlipTo(state: CardState) {
        let from: UIView, to: UIView
        let transition: AnimationOptions

        if state == .front {
            from = back
            to = front
            transition = .transitionFlipFromRight
        } else {
            from = front
            to = back
            transition = .transitionFlipFromLeft
        }

        UIView.transition(from: from, to: to, duration: 0, options: [transition, .showHideTransitionViews])
    }

    func animateMatch() {
        transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    }

    func animateCompleteGame() {
        transform = CGAffineTransform(scaleX: 1, y: 1)
    }

    func updateAfterRotateOrResize() {
        DispatchQueue.main.async { [weak self] in
            self?.updateImagesSize()
        }

        if card?.state == .matched {
            DispatchQueue.main.async { [weak self] in
                self?.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            }
        }
    }

    private func build() {
        let size = frame.size

        front = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        front.contentMode = .scaleAspectFit
        front.isHidden = true

        back = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        back.contentMode = .scaleAspectFit

        addSubview(front)
        addSubview(back)
    }

    private func reset(state: CardState) {
        cancelAnimations()

        var flipTarget: CardState
        var scaleFactor: CGFloat

        updateImagesSize()

        switch state {
        case .back:
            flipTarget = .back
            scaleFactor = 1
        case .front:
            flipTarget = .front
            scaleFactor = 1
        case .matched:
            flipTarget = .front
            scaleFactor = 0.6
        case .complete:
            flipTarget = .front
            scaleFactor = 1
        }

        animateFlipTo(state: flipTarget)
        DispatchQueue.main.async { [weak self] in
            self?.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        }
    }

    private func updateImagesSize() {
        let size = frame.size

        front.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        back.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }

    private func cancelAnimations() {
        layer.removeAllAnimations()
        front.layer.removeAllAnimations()
        back.layer.removeAllAnimations()
    }

    private func getFacingSide() -> CardState {
        if back.isHidden {
            return .front
        }

        return .back
    }
}
