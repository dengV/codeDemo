//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.


import UIKit

class ABCLiveGameAddScoreToTeamsPlayerSelectionTableViewCell: UITableViewCell {

    enum StatMode {
        case Goal
        case Assist
        case Unselected
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var goalAssistStatLabel: UILabel!
    var statMode: StatMode = .Unselected {
        didSet {

            // Flip the label text based on selected state
            switch statMode {
            case .Goal:
                self.goalAssistStatLabel.text = "Goal"
                self.goalAssistStatLabel.isHidden = false
            case .Assist:
                self.goalAssistStatLabel.text = "Assist"
                self.goalAssistStatLabel.isHidden = false

            case .Unselected:
                self.goalAssistStatLabel.isHidden = true
                self.goalAssistStatLabel.text = ""
            }

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state

        print(#function + " " + "setSelected")
    }


}
