//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.

import Foundation
import RealmSwift

class ABCGameDataStore: NSObject {

    // MARK: - Properties

    // The singletone object getter
    static let sharedInstance = ABCGameDataStore()

    // A predicate to get object that needs to be filtered or sorted.
    var targetPredicate: NSPredicate?

    // An alternative to let the app manually fetch data from the server in case the server does not support push notification for newly-updates data yet.
    var gamesForLeagueFetchedFromThisLaunch = false


    // MARK: - Methods

    // Init the realm object in each method help the object lazy init the realm without let the object itself to get init,
    // And also keep the code mobile
    func addOrUpdateAnABCGame(ABCGame: ABCGame) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(ABCGame, update: true)
            }
        } catch let error as NSError {
            print("\(#function) + \(error)")
        }
    }

    func getAnABCGame(atIndex index: Int) -> ABCGame? {
        do {
            let realm = try Realm()
            let theABCGameToReturn = realm.objects(ABCGame.self)[index]
            return theABCGameToReturn

        } catch let error as NSError {
            print("\(#function) + \(error)")
        }

        return nil
    }

    func getAnABCGame(byPrimaryKey primaryKey: String) -> ABCGame? {

        do {
            let realm = try Realm()
            let theABCGameToReturn = realm.objects(ABCGame.self).filter("id == %@", primaryKey).first
            return theABCGameToReturn

        } catch let error as NSError {
            print("\(#function) + \(error)")
        }

        return nil

    }

    func getAllABCGames(byPredicate predicate: NSPredicate?) -> Results<ABCGame>? {


        if let validTargetPredicate = predicate {
            self.targetPredicate = nil
            return self.getAllABCGames(byPredicate: validTargetPredicate)
        } else {

            /*
             do {
             let realm = try Realm()
             let allABCGamesToReturn = realm.objects(ABCGame.self)
             return allABCGamesToReturn

             } catch let error as NSError {
             print("\(#function) + \(error)")
             }

             */

            return nil

        }

    }


    // fileprivate as internal method that is only exposed to this file
    fileprivate func getAllABCGames(byPredicate predicate: NSPredicate) -> Results<ABCGame>? {

        print(#function + " " + "\(predicate.predicateFormat)")

        do {
            let realm = try Realm()
            let allABCGamesToReturn = realm.objects(ABCGame.self).filter(predicate)

            return allABCGamesToReturn

        } catch let error as NSError {
            print("\(#function) + \(error)")
        }

        return nil
    }


    func updateAnABCGame(atIndex index: Int, withToUpdateValueDictionary toUpdateValueDictionary: [String: Any]) {

        guard let theTargetABCGameToUpdate = self.getAnABCGame(atIndex: index) else {
            print("\(#function) + can't get the target ABC Game to update by calling the \(#selector(ABCGameDataStore.getAnABCGame(atIndex:)))")
            return
        }

        self.updateAnABCGame(forTargetABCGameToUpdate: theTargetABCGameToUpdate, withToUpdateValueDictionary: toUpdateValueDictionary)

    }

    func updateAnABCGame(forTargetABCGameToUpdate targetABCGameToUpdate: ABCGame, withToUpdateValueDictionary toUpdateValueDictionary: [String: Any]) {


        var toUpdateValueDictionaryWithPrimaryKey = [String: Any]()
        toUpdateValueDictionaryWithPrimaryKey["id"] = targetABCGameToUpdate.id
        toUpdateValueDictionary.forEach { (key, value) in
            toUpdateValueDictionaryWithPrimaryKey[key] = value
        }

        do {
            let realm = try Realm()
            try realm.write {
                realm.create(ABCGame.self, value: toUpdateValueDictionaryWithPrimaryKey, update: true)
            }

        } catch let error as NSError {
            print("\(#function) + \(error)")
        }

    }

    // Method that get data from Web Service
    // Use a closure to report the response to the object that calls this method.
    func getAllABCGamesForTeamAndMonthFromABCWebService(yearOfGame: String, monthOfGame: String, manualRefresh: Bool?, completion: @escaping (_ allABCPlayerUsersForMySeason: [ABCGame]) -> Void) {

        var allABCGamesToReturn = [ABCGame]()
        var allGamesToReturnTargetCount = 0

        guard let theLoggedInABCAppUser:ABCAppUser = ABCAppUserDataStore.sharedInstance.getTheOnlyABCAppUser() ,
            let userIDInStore = theLoggedInABCAppUser.authUuid,
            let authTokenInStore = theLoggedInABCAppUser.authToken,
            let targetTeamIDInStore = theLoggedInABCAppUser.loggedInAppUserAssociatedTeams.first?.id else {
                print(#function + " Can't find valid authToken and UserID Pair and team Id from User Defaults")
                return
        }

        let targetPredicate = self.getPredicateMatchingYearAndMonth(withTargetYear: yearOfGame, withTargetMonth: monthOfGame)

        if manualRefresh != true {

            if let validTargetABCGamesFromStorageToReturn = self.getAllABCGames(byPredicate: targetPredicate) {

                var allABCGamesFromStorageToReturn = [ABCGame]()

                if validTargetABCGamesFromStorageToReturn.count > 0 {

                    validTargetABCGamesFromStorageToReturn.forEach({ (ABCGame:ABCGame) in
                        allABCGamesFromStorageToReturn.append(ABCGame)
                    })

                    completion(allABCGamesFromStorageToReturn)
                    return
                }
            }
        }

        // Fetch the data from the server,
        // Call another NSURLSession/AlamoFire wrapper to get the data.
        ABCWebServiceHandler.fetchGamesForTeamAndMonthFromABCWebService(withUserID: userIDInStore, andAuthToken: authTokenInStore, andTeamID: targetTeamIDInStore, andYearOfGame: yearOfGame, AndMonthOfGame: monthOfGame) { (allGamesForTeamAndMonth:[[String : Any]]) in

            print(#function + " get allGamesForTeamAndMonth \(allGamesForTeamAndMonth) from  fetchGamesForTeamAndMonthFromABCWebService")

            if allGamesForTeamAndMonth.isEmpty {
                completion([ABCGame]())
            }

            allGamesForTeamAndMonth.forEach({ (allInfoOfTargetGameForTeamAndMonthResponseJSON:[String : Any]) in

                allGamesToReturnTargetCount = allGamesToReturnTargetCount + 1

                guard let oneABCGameWithFullDetailInfo = ABCWebServiceJSONResponseParser.parseToGetABCGameForTeamAndMonthWithFullInfoFromWebServiceGameEndpoints(fromABCWebServiceResponse: allInfoOfTargetGameForTeamAndMonthResponseJSON) else {
                    print(#function + " Can't get allABCGamesWithFullDetailInfo from ABCWebServiceJSONResponseParser.parseToGetABCGamesWithFullInfoFromWebServiceGameEndpoints ")
                    return
                }

                allABCGamesToReturn.append(oneABCGameWithFullDetailInfo)

                if allABCGamesToReturn.count == allGamesToReturnTargetCount {
                    completion(allABCGamesToReturn)
                }

            })
        }
    }


    // Method that get data from Web Service
    // Use a closure to report the response to the object that calls this method.
    func getAllABCGamesForLeagueAndMonthFromABCWebService(yearOfGame: String, monthOfGame: String, manualRefresh: Bool?, completion: @escaping (_ allABCPlayerUsersForMySeason: [ABCGame]) -> Void) {

        var allABCGamesToReturn = [ABCGame]()
        var allGamesToReturnTargetCount = 0


        guard let theLoggedInABCAppUser:ABCAppUser = ABCAppUserDataStore.sharedInstance.getTheOnlyABCAppUser() ,
            let userIDInStore = theLoggedInABCAppUser.authUuid,
            let authTokenInStore = theLoggedInABCAppUser.authToken,
            let targetLeagueIDInStore = theLoggedInABCAppUser.loggedInAppUserAssociatedLeagues.first?.id else {
                print(#function + " Can't find valid authToken and UserID Pair and league Id from User Defaults")
                return
        }

        if manualRefresh != true {
            if self.gamesForLeagueFetchedFromThisLaunch {
                let targetPredicate = self.getPredicateMatchingYearAndMonth(withTargetYear: yearOfGame, withTargetMonth: monthOfGame)

                if let validTargetABCGamesFromStorageToReturn = self.getAllABCGames(byPredicate: targetPredicate) {

                    var allABCGamesFromStorageToReturn = [ABCGame]()

                    if validTargetABCGamesFromStorageToReturn.count > 0 {

                        validTargetABCGamesFromStorageToReturn.forEach({ (ABCGame:ABCGame) in
                            allABCGamesFromStorageToReturn.append(ABCGame)
                        })

                        completion(allABCGamesFromStorageToReturn)
                        return
                    }
                }
            }
        }
        // Fetch the data from the server,
        // Call another NSURLSession/AlamoFire wrapper to get the data.
        ABCWebServiceHandler.fetchGamesForLeagueAndMonthFromABCWebService(withUserID: userIDInStore, andAuthToken: authTokenInStore, andLeagueID: targetLeagueIDInStore, andYearOfGame: yearOfGame, AndMonthOfGame: monthOfGame) { (allGamesForLeagueAndMonth:[[String : Any]]) in


            print(#function + " get allGamesForTeamAndMonth \(allGamesForLeagueAndMonth) from  fetchGamesForTeamAndMonthFromABCWebService")

            if allGamesForLeagueAndMonth.isEmpty {
                completion([ABCGame]())
            }

            allGamesForLeagueAndMonth.forEach({ (allInfoOfTargetGameForTeamAndMonthResponseJSON:[String : Any]) in

                allGamesToReturnTargetCount = allGamesToReturnTargetCount + 1

                guard let oneABCGameWithFullDetailInfo = ABCWebServiceJSONResponseParser.parseToGetABCGameForTeamAndMonthWithFullInfoFromWebServiceGameEndpoints(fromABCWebServiceResponse: allInfoOfTargetGameForTeamAndMonthResponseJSON) else {
                    print(#function + " Can't get allABCGamesWithFullDetailInfo from ABCWebServiceJSONResponseParser.parseToGetABCGamesWithFullInfoFromWebServiceGameEndpoints ")
                    return
                }

                allABCGamesToReturn.append(oneABCGameWithFullDetailInfo)
                
                if allABCGamesToReturn.count == allGamesToReturnTargetCount {
                    self.gamesForLeagueFetchedFromThisLaunch = true
                    completion(allABCGamesToReturn)
                }
                
                
            })
            
        }
        
    }

    // Method that get data from Web Service
    // Use a closure to report the response to the object that calls this method.
    func getAllABCGamesForSeasonsFromABCWebService(completion: @escaping (_ allABCPlayerUsersForMySeason: [ABCGame]) -> Void) {

        var allABCGamesToReturn = [ABCGame]()
        var allGamesToReturnTargetCount = 0

        guard let theLoggedInABCAppUser:ABCAppUser = ABCAppUserDataStore.sharedInstance.getTheOnlyABCAppUser() ,
            let userIDInStore = theLoggedInABCAppUser.authUuid,
            let authTokenInStore = theLoggedInABCAppUser.authToken else {
                print(#function + " Can't find valid authToken and UserID Pair and team Id from User Defaults")
                return

        }

        guard let theFirstLeagueOfLoggedUser: ABCLeague = theLoggedInABCAppUser.loggedInAppUserAssociatedLeagues.first,
            let theFirstDivisionOfLoggedUser: ABCDivision = theFirstLeagueOfLoggedUser.allAssociatedDivisions.first,
            let IDOftheFirstDivisionOfLoggedUser: String = theFirstDivisionOfLoggedUser.id

            else {
                print(#function + " Can't get IDOftheFirstDivisionOfLoggedUser ")
                return
        }

        // Fetch the data from the server,
        // Call another NSURLSession/AlamoFire wrapper to get the data.
        ABCWebServiceHandler.fetchAllSeasonsForDivisionOfAnABCPlayerUsersFromABCWebService(withUserID: userIDInStore, andAuthToken: authTokenInStore, andDivisionID: IDOftheFirstDivisionOfLoggedUser) { allSeasonsWithAssociatedGamesForDivisionResponseJSON in

            print(#function + " get allSeasonsForDivisionResponseJSON \(allSeasonsWithAssociatedGamesForDivisionResponseJSON) from  ABCWebServiceHandler.fetchAllSeasonsForDivisionOfAnABCPlayerUsersFromABCWebService")

            guard let allABCSeasonsForLoggedUser = ABCWebServiceJSONResponseParser.parseToGetABCSeasonsForTargetDivision(fromABCWebServiceResponse: allSeasonsWithAssociatedGamesForDivisionResponseJSON) else {
                print(#function + " Can't get allABCSeasonsForLoggedUser from ABCWebServiceJSONResponseParser.parseToGetABCSeasonsForTargetDivision")
                return
            }

            print(#function + " Get allABCSeasonsForLoggedUser \(allABCSeasonsForLoggedUser.description)")

            allABCSeasonsForLoggedUser.forEach({ oneABCSeason in

                oneABCSeason.gamesInSeason.forEach({ oneABCGameInTargetSeason in

                    allGamesToReturnTargetCount = allGamesToReturnTargetCount + 1

                    guard let idOfOneABCGameInTargetSeason = oneABCGameInTargetSeason.id else {
                        print(#function + " Can't get idOfOneABCGameInTargetSeason " )
                        return
                    }

                    print(#function  + " ready to fech game with GameID \(idOfOneABCGameInTargetSeason)" )

                    ABCWebServiceHandler.fetchGameInfoFromABCWebService(withUserID: userIDInStore, andAuthToken: authTokenInStore, andGameID: idOfOneABCGameInTargetSeason, completion: { allInfoOfTargetGameResponseJSON in


                        print(#function + " Received allGamesInfoResponseJSON \(allInfoOfTargetGameResponseJSON)")

                        guard let oneABCGameWithFullDetailInfo = ABCWebServiceJSONResponseParser.parseToGetABCGameWithFullInfoFromWebServiceGameEndpoints(fromABCWebServiceResponse: allInfoOfTargetGameResponseJSON) else {
                            print(#function + " Can't get allABCGamesWithFullDetailInfo from ABCWebServiceJSONResponseParser.parseToGetABCGamesWithFullInfoFromWebServiceGameEndpoints ")
                            return
                        }

                        allABCGamesToReturn.append(oneABCGameWithFullDetailInfo)

                        if allABCGamesToReturn.count == allGamesToReturnTargetCount {
                            completion(allABCGamesToReturn)
                        }

                    })

                })

            })

        }

    }


    // Method that get data from Web Service
    // Use a closure to report the response to the object that calls this method.
    func getTargetABCGameFromABCWebService(withGameID gameID: String, manualRefresh: Bool?, completion: @escaping (_ targetABCGame: ABCGame?) -> Void) {

        guard let theLoggedInABCAppUser:ABCAppUser = ABCAppUserDataStore.sharedInstance.getTheOnlyABCAppUser() ,
            let userIDInStore = theLoggedInABCAppUser.authUuid,
            let authTokenInStore = theLoggedInABCAppUser.authToken else {
                print(#function + " Can't find valid authToken and UserID Pair from storage")
                return

        }


        if let validCurrentTargetABCGameInStore = self.getAnABCGame(byPrimaryKey: gameID) {
            if validCurrentTargetABCGameInStore.isFault.value == false && validCurrentTargetABCGameInStore.triedUpdate.value != true && manualRefresh != true {
                completion(validCurrentTargetABCGameInStore)
                return
            }
        }


        print(#function + " " + "Can't the validCurrentTargetABCGameInStore")

        // Fetch the data from the server,
        // Call another NSURLSession/AlamoFire wrapper to get the data.
        ABCWebServiceHandler.fetchGameInfoFromABCWebService(withUserID: userIDInStore, andAuthToken: authTokenInStore, andGameID: gameID, completion: { allInfoOfTargetGameResponseJSON in


            print(#function + " Received allGamesInfoResponseJSON \(allInfoOfTargetGameResponseJSON)")

            guard let oneABCGameWithFullDetailInfo = ABCWebServiceJSONResponseParser.parseToGetABCGameWithFullInfoFromWebServiceGameEndpoints(fromABCWebServiceResponse: allInfoOfTargetGameResponseJSON) else {
                print(#function + " Can't get allABCGamesWithFullDetailInfo from ABCWebServiceJSONResponseParser.parseToGetABCGamesWithFullInfoFromWebServiceGameEndpoints ")

                completion(nil)
                return
            }

            completion(oneABCGameWithFullDetailInfo)

        })

    }


    // MARK: fileprivate methods
    fileprivate func getPredicateMatchingYearAndMonthInDate(date: Date) -> NSPredicate? {

        let dateComponentsSet = Set<Calendar.Component>([Calendar.Component.year,Calendar.Component.month])
        let targetDateComponents = Calendar.current.dateComponents(dateComponentsSet, from: date)
        guard let targetYear = targetDateComponents.year else { return nil }
        guard let targetMonth = targetDateComponents.month else { return nil }


        var startDateComponents = DateComponents()
        startDateComponents.year = targetYear
        startDateComponents.month = targetMonth
        guard let startDateOfMonth = Calendar.current.date(from: startDateComponents) else { return nil }

        var dateComponentsToAdjust = DateComponents()
        dateComponentsToAdjust.year = 0
        dateComponentsToAdjust.month = 1
        dateComponentsToAdjust.day = -1
        guard let endDateOfMonth = Calendar.current.date(byAdding: dateComponentsToAdjust, to: startDateOfMonth) else { return nil }

        let predicate = NSPredicate(format: "gameStartDate >= %@ AND gameStartDate <= %@", startDateOfMonth as CVarArg,endDateOfMonth as CVarArg)
        
        return predicate
        
    }
    
    fileprivate func getPredicateMatchingYearAndMonth(withTargetYear targetYear: String, withTargetMonth targetMonth: String) -> NSPredicate? {
        
        guard let targetYearInt = Int(targetYear) else { return nil }
        guard let targetMonthInt = Int(targetMonth) else { return nil }
        
        var startDateComponents = DateComponents()
        startDateComponents.year = targetYearInt
        startDateComponents.month = targetMonthInt
        guard let startDateOfMonth = Calendar.current.date(from: startDateComponents) else { return nil }
        
        var dateComponentsToAdjust = DateComponents()
        dateComponentsToAdjust.year = 0
        dateComponentsToAdjust.month = 1
        dateComponentsToAdjust.day = -1
        guard let endDateOfMonth = Calendar.current.date(byAdding: dateComponentsToAdjust, to: startDateOfMonth) else { return nil }
        
        let predicate = NSPredicate(format: "gameStartDate >= %@ AND gameStartDate <= %@", startDateOfMonth as CVarArg,endDateOfMonth as CVarArg)
        
        return predicate
        
    }
    
    
}
