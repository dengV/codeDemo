//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.

import Foundation
import RealmSwift

class ABCGameInfoTableViewDataSource: NSObject, UITableViewDataSource {

    // The singletone object getter
    var abcGameDataStore = ABCGameDataStore.sharedInstance

    // A predicate to get object that needs to be filtered or sorted.
    var targetPredicate: NSPredicate?
    var bindHostingViewController: UIViewController?

    init(targetPredicte predicate: NSPredicate?) {
        self.targetPredicate = predicate
        super.init()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let allABCGames = self.abcGameDataStore.getAllABCGames(byPredicate: targetPredicate) else {
            return 0
        }
        return allABCGames.count

    }

    func reloadData(forTableView tableView: UITableView, withPredicate predicate: NSPredicate) {

        guard tableView.dataSource is ABCGameInfoTableViewDataSource else { return }
        self.targetPredicate = predicate
        tableView.reloadData()

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ABCGameInfoTableViewCell", for: indexPath) as! ABCGameInfoTableViewCell
        cell.bindIndexPath = indexPath
        cell.bindTableViewHostingController = self.bindHostingViewController as! ABCGameInfoTableViewCellBindTableViewHostingControllerDelegate

        func getCellWithInvalidInfoIndication() -> UITableViewCell {
            let cellWithInvalidInfoIndication = UITableViewCell(style: .default, reuseIdentifier: nil)
            cellWithInvalidInfoIndication.textLabel?.text = "Row with Invalid Data"
            return cellWithInvalidInfoIndication
        }

        func provideDataToCell(fromABCGame providedABCGame:ABCGame) {

            cell.abcGameDateLabel.text = providedABCGame.gameStartDate?.displayForABCGameSummaryTableViewCell() ?? "na"

            cell.abcGameAwayTeamLabel.text = providedABCGame.awayTeamName ?? "na"
            cell.abcGameHomeTeamLabel.text = providedABCGame.homeTeamName != nil ? "at \(providedABCGame.homeTeamName!)" : "na"

            if let awayTeamScore = providedABCGame.awayTeamScore.value,
                let homeTeamScore = providedABCGame.homeTeamScore.value {
                cell.abcGameResultLabel.text = "\(awayTeamScore) - \(homeTeamScore)"
            } else {
                cell.abcGameResultLabel.text = "na"
            }

            cell.abcGameVenueLabel.text = providedABCGame.gameVenue ?? "na"

        }

        func configureCellUIAppearance(forCell cell: ABCGameInfoTableViewCell, byABCGame providedABCGame:ABCGame){

            if providedABCGame.isLive {
                cell.abcGameDateLabel.textColor = UIColor.blue
                cell.abcGameHomeTeamLabel.textColor = UIColor.blue
                cell.abcGameAwayTeamLabel.textColor = UIColor.blue
                cell.backgroundColor = UIColor.ABCLiveGameTableViewCellBackgroundColor
            }

        }

        guard let allABCGames = self.abcGameDataStore.getAllABCGames(byPredicate: targetPredicate) else {
            return getCellWithInvalidInfoIndication()
        }
        let abcGameToShow = allABCGames[indexPath.row]
        provideDataToCell(fromABCGame: abcGameToShow)
        configureCellUIAppearance(forCell: cell, byABCGame: abcGameToShow)


        return cell
    }

}
