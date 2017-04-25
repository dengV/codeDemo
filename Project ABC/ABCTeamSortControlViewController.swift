//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.

import UIKit

class ABCTeamSortControlViewController: ABCAbstractSortControlViewController {

    // MARK: - An alternative to access the keyPath of the object for filtering or sorting.
    enum SortBy: String, ABCAbstractSortBy {
        case Team
        case GamePlayed = "Game Played"
        case GameWon = "Game Won"
        case GameLost = "Game Lost"
        case TotalGames = "Total Games"
        case TotalPoints = "Total Points"

        static var allValues: [ABCAbstractSortBy] = {
            return [Team, GamePlayed, GameWon, GameLost, TotalGames,TotalPoints]
        }()

    }

    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        self.dismissABCTeamSortControlViewController()
    }

    func dismissABCTeamSortControlViewController(){
        self.abcAbstractControlViewControllerPresentingViewController.unwindByDismissingABCAbstractSortControlViewController(abcAbstractControlViewController: self)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SortBy.allValues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Use 'guard' syntax to safely get the casted table view cell by cell identifier
        guard let abcTeamSortControlViewControllerTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ABCSortTableViewCell", for: indexPath) as? ABCSortTableViewCell else {
            return UITableViewCell()
        }

        abcTeamSortControlViewControllerTableViewCell.bindIndexPath = indexPath
        abcTeamSortControlViewControllerTableViewCell.abcSortTableViewCellReferencedController = self

        guard let selectedSortBy = SortBy.allValues[indexPath.row] as? SortBy else {

            abcTeamSortControlViewControllerTableViewCell.sortkeyPathTitleLabel?.text = "Found no valid case to sort."
            return abcTeamSortControlViewControllerTableViewCell

        }

        abcTeamSortControlViewControllerTableViewCell.sortkeyPathTitleLabel?.text = selectedSortBy.rawValue

        return abcTeamSortControlViewControllerTableViewCell
    }

}

// Adopting the protocols by Swift extension for clarity

extension ABCTeamSortControlViewController: ABCSortTableViewCellReferencedControllerDelegate {

    func didPickAscendingSegmentedControl(withIndexPath indexPath: IndexPath, andTargetAscending targetAscending: Bool) {

        let sortByToPassBackToABCAbstractSortControlViewControllerPresentingViewController = SortBy.allValues[indexPath.row]

        self.abcAbstractControlViewControllerPresentingViewController.unwindByMakeSelectionInABCAbstractSortControlViewController(abcAbstractControlViewController: self, withSortBy: sortByToPassBackToABCAbstractSortControlViewControllerPresentingViewController, ascending: targetAscending)
        
    }

}
