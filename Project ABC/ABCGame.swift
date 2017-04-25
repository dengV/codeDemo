//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.


import Foundation
import RealmSwift

class ABCGame: Object {

    // MARK: - An alternative to access the keyPath of the object for filtering or sorting.
    enum PropertiesName: String {
        case id
        case isFault
        case triedUpdate
        case gameStartDate
        case gameStartMonth
        case gameStartYear
        case isFinished
        case isLive
        case homeTeamName
        case awayTeamName
        case homeTeamId
        case awayTeamId
        case homeTeamScore
        case awayTeamScore
        case gameVenue
        case scoringUpdates
        case penalties
        case attendances
        case periods

    }

    // MARK: - Properties
    dynamic var id: String?
    let isFault = RealmOptional<Bool>()
    let triedUpdate = RealmOptional<Bool>()
    dynamic var gameStartDate: Date?
    dynamic var gameStartMonth: String? {
        guard let validGameStartDate = gameStartDate else { return nil }
        let dateComponentsSet = Set<Calendar.Component>([Calendar.Component.month])
        let targetDateComponents = Calendar.current.dateComponents(dateComponentsSet, from: validGameStartDate)
        return "\(targetDateComponents.month)"
    }

    dynamic var gameStartYear: String? {
        guard let validGameStartDate = gameStartDate else { return nil }
        let dateComponentsSet = Set<Calendar.Component>([Calendar.Component.year])
        let targetDateComponents = Calendar.current.dateComponents(dateComponentsSet, from: validGameStartDate)
        return "\(targetDateComponents.year)"
    }

    let isFinished = RealmOptional<Bool>()
    var isLive:Bool {
        if let validGameStaretDate = gameStartDate {
            if validGameStaretDate < Date() && isFinished.value == false {
                return true
            }
        }
        return false
    }

    dynamic var homeTeamName: String?
    dynamic var awayTeamName: String?
    dynamic var homeTeamId: String?
    dynamic var awayTeamId: String?
    let homeTeamScore = RealmOptional<Int>()
    let awayTeamScore = RealmOptional<Int>()
    dynamic var gameVenue: String?
    let scoringUpdates = List<ABCGameScoring>()
    let penalties = List<ABCGamePenalty>()
    let attendances = List<ABCGameAttendance>()
    let periods = List<ABCGamePeriod>()

    // MARK: - Methods

    // The primaryKey is for Realm to access the object in the persistent storage efficiently
    override static func primaryKey() -> String? {
        return "id"
    }

    // Init the realm object in each method help the object lazy init the realm without let the object itself to get init,
    // And also keep the code mobile
    func addAnAssociatedGameScoringUpdate(ABCGameScoringUpdate: ABCGameScoring) {
        do {
            let realm = try Realm()
            try realm.write {
                self.scoringUpdates.append(ABCGameScoringUpdate)
            }
        } catch let error as NSError {
            print("\(#function) + \(error)")
        }
    }

    func addAnAssociatedGamePenalty(ABCGamePenalty: ABCGamePenalty) {
        do {
            let realm = try Realm()
            try realm.write {
                self.penalties.append(ABCGamePenalty)
            }
        } catch let error as NSError {
            print("\(#function) + \(error)")
        }
    }

    func addAnAssociatedAttendance(ABCGameAttendance: ABCGameAttendance) {
        do {
            let realm = try Realm()
            try realm.write {
                self.attendances.append(ABCGameAttendance)
            }
        } catch let error as NSError {
            print("\(#function) + \(error)")
        }
    }

    func addAnAssociatedPeriod(ABCGamePeriod: ABCGamePeriod) {
        do {
            let realm = try Realm()
            try realm.write {
                self.periods.append(ABCGamePeriod)
            }
        } catch let error as NSError {
            print("\(#function) + \(error)")
        }
    }

    func updateGameProperties(keyValueToUpdate: [String: Any]){

        do {
            let realm = try Realm()
            try realm.write {
                for (key, value) in keyValueToUpdate {
                    self.setValue(value, forKey: key)
                }
            }
        } catch let error as NSError {
            print("\(#function) + \(error)")
        }


    }
  
}
