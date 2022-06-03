//
//  UnmatchedCardsAnimator.swift
//  Milestone10
//
//  Created by Brian Coleman on 2022-06-02.
//

import UIKit

class UnmatchedCardsAnimator {
    private static let flipDuration = 0.3
    private static let waitDuration = 1.0

    private var flipToFrontAnimator: UIViewPropertyAnimator?
    private var dispatchWorkItem: DispatchWorkItem?
    private var flipToBackAnimator: UIViewPropertyAnimator?

    func start(oldCell: CardCell, newCell: CardCell, completion: (() -> ())? = nil) {
        flipToFront(oldCell: oldCell, newCell: newCell, completion: completion)
    }

    func cancel() {
        dispatchWorkItem?.cancel()
        dispatchWorkItem = nil

        flipToFrontAnimator?.stopAnimation(true)
        flipToFrontAnimator = nil

        flipToBackAnimator?.stopAnimation(true)
        flipToBackAnimator = nil
    }

    func forceFlipToBack(oldCell: CardCell, newCell: CardCell) {
        cancel()
        flipToBack(oldCell: oldCell, newCell: newCell)
    }

    private func flipToFront(oldCell: CardCell, newCell: CardCell, completion: (() -> ())? = nil) {
        flipToFrontAnimator = UIViewPropertyAnimator(duration: UnmatchedCardsAnimator.flipDuration, timingParameters: UICubicTimingParameters())

        flipToFrontAnimator?.addAnimations {
            newCell.animateFlipTo(state: .front)
        }

        flipToFrontAnimator?.addCompletion { [weak self] _ in
            self?.wait(oldCell: oldCell, newCell: newCell, completion: completion)
            self?.flipToFrontAnimator = nil
        }

        flipToFrontAnimator?.startAnimation()
    }

    private func wait(oldCell: CardCell, newCell: CardCell, completion: (() -> ())? = nil) {
        dispatchWorkItem = DispatchWorkItem { [weak self] in
            self?.flipToBack(oldCell: oldCell, newCell: newCell, completion: completion)
            self?.dispatchWorkItem = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + UnmatchedCardsAnimator.waitDuration, execute: dispatchWorkItem!)
    }

    private func flipToBack(oldCell: CardCell, newCell: CardCell, completion: (() -> ())? = nil) {
        flipToBackAnimator = UIViewPropertyAnimator(duration: UnmatchedCardsAnimator.flipDuration, timingParameters: UICubicTimingParameters())

        flipToBackAnimator?.addAnimations {
            oldCell.animateFlipTo(state: .back)
            newCell.animateFlipTo(state: .back)
        }

        flipToBackAnimator?.addCompletion { [weak self] position in
            self?.flipToBackAnimator = nil
            if position == .end {
                completion?()
            }
        }

        flipToBackAnimator?.startAnimation()
    }
}
