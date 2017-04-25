//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.

import UIKit

// Protocol for the parent object (such as: View Controller) to adopt for handling dimiss the current view controller and passing data from the child object to the parent object.

protocol ABCGameDetailViewControllerPresentingViewControllerProtocol {
    func unwindFromABCGameDetailViewController()
}

class ABCGameDetailViewController: UIViewController, ABCLiveGameGoalAssistInfoViewControllerPresentingViewControllerProtocol {


    // MARK: - Outlet

    @IBOutlet weak var loadProgressIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var gameDetailTableView: UITableView!
    @IBOutlet weak var gameSummaryView: UIView!
    @IBOutlet weak var teamAwayNameLabel: UILabel!
    @IBOutlet weak var teamHomeNameLabel: UILabel!
    @IBOutlet weak var teamAwayScoreLabel: UILabel!
    @IBOutlet weak var teamHomeScoreLabel: UILabel!
    @IBOutlet weak var gameVenueLabel: UILabel!
    @IBOutlet weak var gameTimeLabel: UILabel!
    @IBOutlet weak var gameRefereeLabel: UILabel!
    @IBOutlet weak var teamAwayAddScoreButton: UIButton!
    @IBOutlet weak var teamHomeAddScoreButton: UIButton!

    // MARK: - Properties

    var targetABCGameId: String!
    var abcGame: ABCGame? 
    var abcGameDataStore = ABCGameDataStore.sharedInstance
    var gameDetailTableViewDataSource = ABCGameDetailTableViewDataSource()
    var abcGameDetailViewControllerPresentingViewController: ABCGameDetailViewControllerPresentingViewControllerProtocol!
    var isLiveGameMode = false {
        didSet {
            self.setupAddScoreButtons()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupPullToRefreshControl()

        print(#function + " " + "🚕🚕🚕🚕🚕🚕GameID: \(targetABCGameId)")

        abcGameDataStore.getTargetABCGameFromABCWebService (withGameID: targetABCGameId, manualRefresh: nil) { (fetchedABCGame: ABCGame?) in

            self.setupUI(withTargetABCGame: fetchedABCGame)

        }

    }


    override func viewWillDisappear(_ animated: Bool) {

        self.abcGameDetailViewControllerPresentingViewController.unwindFromABCGameDetailViewController()
    }

    func setupUI(withTargetABCGame targetABCGame: ABCGame?){

        self.setupAddScoreButtons()

        guard let validTargetABCGame = targetABCGame else {
            print(#function + " " + "Can't get validTargetABCGame")

            self.showCoreView(toShow: false, forSeconds: 1.0)

            return
        }

        self.showCoreView(toShow: true, forSeconds: 1.0)

        self.gameDetailTableViewDataSource.bindHostingViewController = self

        self.gameDetailTableView.dataSource = self.gameDetailTableViewDataSource
        self.gameDetailTableView.delegate = self
        self.abcGame = targetABCGame
        gameDetailTableViewDataSource.targetABCGame = validTargetABCGame
        self.setupUI()

    }

    // MARK: - fileprivate methods
    fileprivate func setupPullToRefreshControl(){

        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(ABCGameDetailViewController.refreshControlPulled(_:)), for: .valueChanged)

        self.gameDetailTableView.refreshControl = refreshControl

    }

    @objc fileprivate func refreshControlPulled(_ sender: UIRefreshControl){

        if sender.isRefreshing {
            print(#function + " " + "The sender is refresh")
            abcGameDataStore.getTargetABCGameFromABCWebService (withGameID: targetABCGameId, manualRefresh: true) { (fetchedABCGame: ABCGame?) in

                self.gameDetailTableView.refreshControl?.endRefreshing()

                self.setupUI(withTargetABCGame: fetchedABCGame)
                
            }

        } else {
            print(#function + " " + "The sender is NOT refresh")
        }
        
    }

    fileprivate func setupUI(){

        self.teamAwayNameLabel.text = self.abcGame?.awayTeamName ?? "na"
        self.teamHomeNameLabel.text = self.abcGame?.homeTeamName ?? "na"
        self.teamAwayScoreLabel.text = self.abcGame?.awayTeamScore.value != nil ? "\(self.abcGame!.awayTeamScore.value!)" : "na"
        self.teamHomeScoreLabel.text = self.abcGame?.homeTeamScore.value != nil ? "\(self.abcGame!.homeTeamScore.value!)" : "na"
        self.gameVenueLabel.text = self.abcGame?.gameVenue ?? "na"
        self.gameTimeLabel.text = self.abcGame?.gameStartDate != nil ? self.abcGame?.gameStartDate?.displayForABCGameDetailTableViewInformationSection() : "na"
        self.gameRefereeLabel.text = "na"

        self.gameDetailTableView.reloadData()
    }

    fileprivate func setupAddScoreButtons(){

        if let validTeamAwayAddScoreButton = self.teamAwayAddScoreButton,
            let validTeamHomeAddScoreButton = self.teamHomeAddScoreButton {

            if isLiveGameMode {

                validTeamAwayAddScoreButton.isHidden = false
                validTeamHomeAddScoreButton.isHidden = false
            } else {
                validTeamAwayAddScoreButton.isHidden = true
                validTeamHomeAddScoreButton.isHidden = true
            }
            
        }

    }

    fileprivate func showCoreView(toShow: Bool, forSeconds seconds: Double) {


        guard self.loadProgressIndicatorView != nil else { return }
        guard self.gameSummaryView != nil else { return }
        guard self.gameDetailTableView != nil else { return }

        if toShow {

            self.loadProgressIndicatorView.disAppearFromHiddenWithDissolveEffect(forSeconds: seconds)
            self.loadProgressIndicatorView.stopAnimating()
            self.gameSummaryView.appearFromHiddenWithDissolveEffect(forSeconds: seconds)
            self.gameDetailTableView.appearFromHiddenWithDissolveEffect(forSeconds: seconds)

        } else {

            self.gameSummaryView.disAppearFromHiddenWithDissolveEffect(forSeconds: seconds)
            self.gameDetailTableView.disAppearFromHiddenWithDissolveEffect(forSeconds: seconds)
            self.loadProgressIndicatorView.appearFromHiddenWithDissolveEffect(forSeconds: seconds)
            self.loadProgressIndicatorView.startAnimating()

        }
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {


        switch segue.identifier {
        case "showAddScoreGoalAndAssistToTeamsView"?:
            if let abcLiveGameGoalAssistInfoViewController: ABCLiveGameGoalAssistInfoViewController = segue.destination as? ABCLiveGameGoalAssistInfoViewController {
                abcLiveGameGoalAssistInfoViewController.abcLiveGameGoalAssistInfoViewControllerPresentingViewController = self
            }

        case "showAddScoreGoalAndAssistToAwayTeamView"?:

            guard let validAwayTeamId = self.abcGame?.awayTeamId else { return }
            let awayTeamAttendance = ABCGameAttendanceDataStore.sharedInstance.getAllABCGameAttendances(byTeamID: validAwayTeamId)
            print(#function + " " + "awayTeamAttendance \(awayTeamAttendance)")

            if let abcLiveGameGoalAssistInfoViewController:ABCLiveGameGoalAssistInfoViewController = segue.destination as? ABCLiveGameGoalAssistInfoViewController {

                abcLiveGameGoalAssistInfoViewController.targetLiveGameAttendances = awayTeamAttendance
                abcLiveGameGoalAssistInfoViewController.abcLiveGameGoalAssistInfoViewControllerPresentingViewController = self
                abcLiveGameGoalAssistInfoViewController.targetABCGame = self.abcGame
                abcLiveGameGoalAssistInfoViewController.homeModeNotAwayMode = false
            }

        case "showAddScoreGoalAndAssistToHomeTeamView"?:

            guard let validHomeTeamId = self.abcGame?.homeTeamId else { return }
            let homeTeamAttendance = ABCGameAttendanceDataStore.sharedInstance.getAllABCGameAttendances(byTeamID: validHomeTeamId)
            print(#function + " " + "homeTeamAttendance \(homeTeamAttendance)")

            if let abcLiveGameGoalAssistInfoViewController:ABCLiveGameGoalAssistInfoViewController = segue.destination as? ABCLiveGameGoalAssistInfoViewController {

                abcLiveGameGoalAssistInfoViewController.targetLiveGameAttendances = homeTeamAttendance
                abcLiveGameGoalAssistInfoViewController.abcLiveGameGoalAssistInfoViewControllerPresentingViewController = self
                abcLiveGameGoalAssistInfoViewController.targetABCGame = self.abcGame
                abcLiveGameGoalAssistInfoViewController.homeModeNotAwayMode = true


            }

        default:
            print(#function + " This line should never be called unless there is uncovered segue")
        }
    }

    func saveLiveGameGoalAssistChangesAndPopBackToGameDetailView() {

        self.showCoreView(toShow: false, forSeconds: 0.0)
        abcGameDataStore.getTargetABCGameFromABCWebService (withGameID: targetABCGameId, manualRefresh: nil) { (fetchedABCGame: ABCGame?) in

            self.setupUI(withTargetABCGame: fetchedABCGame)
            
        }

        let _ = self.navigationController?.popToViewController(self, animated: true)
    }

}


// Adopting the protocols by Swift extension for clarity
extension ABCGameDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 56.0
    }

}

extension ABCGameDetailViewController:ABCGameDetailAttendanceTableViewCellBindTableViewHostingControllerDelegate {

    func tappedAttendanceButton(forIndexPath indexPath: IndexPath) {

        print(#function + " " + "indexPath \(indexPath)")

        let alertController = UIAlertController(title:"Choose your status", message: nil, preferredStyle: .actionSheet)

        let notAttendAction = UIAlertAction(title: "Not Attending", style: .default) { (alertAction: UIAlertAction) in

            print(#function + " " + "Not Attending Selected")
        }
        alertController.addAction(notAttendAction)

        let attendAction = UIAlertAction(title: "Attending", style: .default) { (alertAction: UIAlertAction) in

            print(#function + " " + "Attending Selected")
        }
        alertController.addAction(attendAction)

        let maybeAttendAction = UIAlertAction(title: "Maybe Attending", style: .default) { (alertAction: UIAlertAction) in

            print(#function + " " + "Maybe Attending Selected")
        }
        alertController.addAction(maybeAttendAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction: UIAlertAction) in

            print(#function + " " + "Cancel Selected")
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) { 
            
            
        }
        
    }


}
