import UIKit
import PlaygroundSupport

// extension 1: animate out a UIView
extension UIView {
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }
    }
}

let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 500, height: 100)))
view.backgroundColor = .red

PlaygroundPage.current.liveView = view
view.bounceOut(duration: 1)

// extension 2: create a times() method for integers
extension Int {
    func times(_ closure: () -> Void) {
        guard self > 0 else { return }

        for _ in 0 ..< self {
            closure()
        }
    }
}

5.times { print("Hello World") }

// extension 3: remove an item from an array
extension Array where Element: Comparable {
    mutating func remove(item: Element) {
        if let location = self.firstIndex(of: item) {
            self.remove(at: location)
        }
    }
}

var test = [1, 2, 3, 4, 1]
test.remove(item: 1)
print(test)
test.remove(item: 1)
print(test)
test.remove(item: 9)
print(test)
