import UIKit

/// Receive user interaction for scrollView
class ScrollViewContainer: UIView {
    var scrollView: UIScrollView?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if view == self {
            return scrollView
        }

        return view
    }
}
