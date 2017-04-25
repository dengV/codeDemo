//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.

import UIKit
import RealmSwift

// Protocol for the parent object (such as: View Controller) to adopt for handling dimiss the current view controller and passing data from the child object to the parent object.

protocol ABCLiveGameGoalAssistInfoViewControllerPresentingViewControllerProtocol {
    func saveLiveGameGoalAssistChangesAndPopBackToGameDetailView()
}

class ABCLiveGameGoalAssistInfoViewController: UIViewController, ABCLiveGamePeriodInfoViewControllerPresentingViewControllerProtocol {

    // MARK: - Outlet
    
    @IBOutlet weak var abcLiveGamePlayerSelectionTableView: UITableView!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var awayTeamScoreLabel: UILabel!
    @IBOutlet weak var homeTeamScoreLabel: UILabel!
    @IBOutlet weak var nextButton: UIBarButtonItem!

    // MARK: - Properties

    var homeModeNotAwayMode: Bool!
    var abcLiveGameGoalAssistInfoViewControllerPresentingViewController: ABCLiveGameGoalAssistInfoViewControllerPresentingViewControllerProtocol!
    var targetABCGame:ABCGame!
    var targetLiveGameAttendances: Results<ABCGameAttendance>?
    var selectedAttendancesIndexPathRows = [IndexPath]() {
        didSet {
            if self.selectedAttendancesIndexPathRows.count > 0 {
                self.nextButton.tintColor = UIColor.white
                self.nextButton.isEnabled = true
            } else {
                self.nextButton.isEnabled = false
                self.nextButton.tintColor = UIColor.clear
            }
        }
    }


    // MARK: Actions

    @IBAction func nextButtonTapped(_ sender: UIBarButtonItem) {

        self.performSegue(withIdentifier: "showPeriodInfoView", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()

    }


    
    // MARK: - fileprivate methods
    fileprivate func setupUI(){

        self.awayTeamNameLabel.text = self.targetABCGame.awayTeamName
        self.homeTeamNameLabel.text = self.targetABCGame.homeTeamName
        self.awayTeamScoreLabel.text = self.targetABCGame.awayTeamScore.value != nil ? "\(self.targetABCGame.awayTeamScore.value!)" : "na"
        self.homeTeamScoreLabel.text = self.targetABCGame.homeTeamScore.value != nil ? "\(self.targetABCGame.homeTeamScore.value!)" : "na"

    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {


        switch segue.identifier {
        case "showPeriodInfoView"?:

            if let abcLiveGamePeriodInfoViewController: ABCLiveGamePeriodInfoViewController = segue.destination as? ABCLiveGamePeriodInfoViewController {

                abcLiveGamePeriodInfoViewController.abcLiveGamePeriodInfoViewControllerPresentingViewController = self
                abcLiveGamePeriodInfoViewController.targetABCGame = self.targetABCGame
                abcLiveGamePeriodInfoViewController.homeModeNotAwayMode = self.homeModeNotAwayMode

                if self.selectedAttendancesIndexPathRows.count >= 1 {

                    let goalPlayerIndexPath:IndexPath = self.selectedAttendancesIndexPathRows[0]
                    guard let goalPlayer = self.targetLiveGameAttendances?[goalPlayerIndexPath.row] else {
                            print(#function + " " + "Can't get goalPlayer ")
                            return
                    }
                    abcLiveGamePeriodInfoViewController.goalPlayerNo1PositionUUID = goalPlayer.positionId


                    if self.selectedAttendancesIndexPathRows.count >= 2 && self.selectedAttendancesIndexPathRows.count <= 3 {
                        for index in 1..<self.selectedAttendancesIndexPathRows.count {

                            let assistPlayerIndexPath:IndexPath = self.selectedAttendancesIndexPathRows[index]
                            guard let assistPlayer = self.targetLiveGameAttendances?[assistPlayerIndexPath.row] else {
                                    print(#function + " " + "Can't get assistPlayer ")
                                    return
                            }

                            if index == 1 {
                                abcLiveGamePeriodInfoViewController.assistPlayerNo2PositionUUID = assistPlayer.positionId
                            } else if index == 2 {
                                abcLiveGamePeriodInfoViewController.assistPlayerNo3PositionUUID = assistPlayer.positionId
                            }
                        }
                    }
                }
            
            }

        default:
            print(#function + " This line should never be called unless there is uncovered segue")
        }

    }

    func saveLiveGameGoalAssistChangesAndPopBackToGameDetailView() {
        self.abcLiveGameGoalAssistInfoViewControllerPresentingViewController.saveLiveGameGoalAssistChangesAndPopBackToGameDetailView()

    }

}

// Adopting the protocols by Swift extension for clarity
extension ABCLiveGameGoalAssistInfoViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let validLiveGameAttendances = self.targetLiveGameAttendances {
            return validLiveGameAttendances.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ABCLiveGameAddScoreToTeamsPlayerSelectionTableViewCell", for: indexPath) as? ABCLiveGameAddScoreToTeamsPlayerSelectionTableViewCell else { return UITableViewCell() }

        guard let oneAttendance:ABCGameAttendance = self.targetLiveGameAttendances?[indexPath.row] else { return UITableViewCell()}


        cell.nameLabel.text = "\(oneAttendance.firstName!) \(oneAttendance.lastName!) (\(oneAttendance.position!))"

        return cell

    }

}

extension ABCLiveGameGoalAssistInfoViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print(#function + " " + "indexPath row \(indexPath.row)")

        if self.selectedAttendancesIndexPathRows.count >= 3 {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }

        guard let cell:ABCLiveGameAddScoreToTeamsPlayerSelectionTableViewCell = tableView.cellForRow(at: indexPath) as? ABCLiveGameAddScoreToTeamsPlayerSelectionTableViewCell else { return }

        if self.selectedAttendancesIndexPathRows.count == 0 {
            cell.statMode = .Goal
        } else {
            cell.statMode = .Assist
        }

        if !selectedAttendancesIndexPathRows.contains(indexPath) {
            self.selectedAttendancesIndexPathRows.append(indexPath)

        }

    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        print(#function + " " + "indexPath row \(indexPath.row)")

        guard let cell:ABCLiveGameAddScoreToTeamsPlayerSelectionTableViewCell = tableView.cellForRow(at: indexPath) as? ABCLiveGameAddScoreToTeamsPlayerSelectionTableViewCell else { return }

        if selectedAttendancesIndexPathRows.contains(indexPath) {
            guard let indexOfIndexPathToRemove = self.selectedAttendancesIndexPathRows.index(of: indexPath) else { return }

            cell.statMode = .Unselected

            self.selectedAttendancesIndexPathRows.remove(at: indexOfIndexPathToRemove)

            if indexOfIndexPathToRemove == 0 {


                self.selectedAttendancesIndexPathRows.forEach { (indexPath: IndexPath) in

                    guard let cell:ABCLiveGameAddScoreToTeamsPlayerSelectionTableViewCell = tableView.cellForRow(at: indexPath) as? ABCLiveGameAddScoreToTeamsPlayerSelectionTableViewCell else { return }
                    cell.statMode = .Unselected
                    tableView.deselectRow(at: indexPath, animated: true)
                }

                self.selectedAttendancesIndexPathRows.removeAll()

            }

        }


    }
}
