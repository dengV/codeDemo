//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.


import UIKit

// Dynamic custom object that can render it self in the Interface Builder
@IBDesignable
class CustomButton: UIButton {

    override var isEnabled: Bool {
        didSet {
            self.setAlphaIfNeeded()
        }
    }

    private func setAlphaIfNeeded(){
        if self.isEnabled == true {
            self.alpha = 1.0
        } else {
            self.alpha = 0.5
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setAlphaIfNeeded()
    }

}
