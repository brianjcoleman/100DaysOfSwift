//
//  FlipCardAnimator.swift
//  Milestone10
//
//  Created by Brian Coleman on 2022-06-02.
//

import UIKit

class FlipCardAnimator {
    static let flipDuration = 0.3

    var flipAnimator: UIViewPropertyAnimator?

    func cancel() {
        flipAnimator?.stopAnimation(true)
        flipAnimator = nil
    }

    func flipTo(state: CardState, cell: CardCell) {
        flipAnimator = UIViewPropertyAnimator(duration: FlipCardAnimator.flipDuration, curve: .linear)

        flipAnimator?.addAnimations {
            cell.animateFlipTo(state: state)
        }

        flipAnimator?.addCompletion { [weak self] _ in
            self?.flipAnimator = nil
        }

        flipAnimator?.startAnimation()
    }
}
