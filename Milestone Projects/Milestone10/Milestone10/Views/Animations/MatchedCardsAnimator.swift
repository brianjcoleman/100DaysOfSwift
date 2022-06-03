//
//  MatchedCardsAnimator.swift
//  Milestone10
//
//  Created by Brian Coleman on 2022-06-02.
//

import UIKit

class MatchedCardsAnimator {
    static let flipDuration = 0.3
    static let matchDuration = 2.0

    var flipToFrontAnimator: UIViewPropertyAnimator?
    var matchAnimator: UIViewPropertyAnimator?

    func cancel() {
        flipToFrontAnimator?.stopAnimation(true)
        flipToFrontAnimator = nil

        matchAnimator?.stopAnimation(true)
        matchAnimator = nil
    }

    func start(oldCell: CardCell, newCell: CardCell, completion: (() -> ())? = nil) {
        flipToFront(oldCell: oldCell, newCell: newCell, completion: completion)
    }

    private func flipToFront(oldCell: CardCell, newCell: CardCell, completion: (() -> ())? = nil) {
        flipToFrontAnimator = UIViewPropertyAnimator(duration: MatchedCardsAnimator.flipDuration, curve: .linear)

        flipToFrontAnimator?.addAnimations {
            newCell.animateFlipTo(state: .front)
        }

        flipToFrontAnimator?.addCompletion { [weak self] _ in
            self?.match(oldCell: oldCell, newCell: newCell, completion: completion)
            self?.flipToFrontAnimator = nil
        }

        flipToFrontAnimator?.startAnimation()
    }

    private func match(oldCell: CardCell, newCell: CardCell, completion: (() -> ())? = nil) {
        let springTiming = UISpringTimingParameters(dampingRatio: 0.3, initialVelocity: CGVector(dx: 5, dy: 5))
        matchAnimator = UIViewPropertyAnimator(duration: MatchedCardsAnimator.matchDuration, timingParameters: springTiming)

        matchAnimator?.addAnimations {
            oldCell.animateMatch()
            newCell.animateMatch()
        }

        matchAnimator?.addCompletion { [weak self] _ in
            self?.matchAnimator = nil
            completion?()
        }

        matchAnimator?.startAnimation()
    }
}
