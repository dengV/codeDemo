//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.


import Foundation

class ABCWebServiceJSONResponseParser {

    class func getPlayerUser(fromABCWebServiceResponse abcWebServiceJSONResponse: [String:Any]) -> ABCPlayer? {

        print(#function + " get abcUserTopLevelData: \(abcWebServiceJSONResponse)")

        return nil
    }


    class func parseToGetPlayerUsersForTeam(fromABCWebServiceResponse abcWebServiceJSONResponseAllABCUserPlayersForTeam: [[String:Any]], forTeamId teamId: String) -> [ABCPlayer]? {

        // Print the ready-to-parse JSON object
        print(#function + " The ABCWebServiceJSONResponseParser received abcWebServiceJSONResponse \(abcWebServiceJSONResponseAllABCUserPlayersForTeam.description) from fromABCWebServiceResponse")

        var allABCPlayerUsersForTeamFromABCWebServiceToReturn = [ABCPlayer]()

        // Use forEach on Collection type to get each enumerated item in the collection
        abcWebServiceJSONResponseAllABCUserPlayersForTeam.forEach { abcWebServiceJSONResponseAnABCUserPlayersForTeam in


            // Use 'guard' syntax to safely get the value for target key from the JSON object
            guard

                let userPlayerID = abcWebServiceJSONResponseAnABCUserPlayersForTeam["uuid"] as? String,
                let firstName = abcWebServiceJSONResponseAnABCUserPlayersForTeam["first_name"] as? String,
                let lastName = abcWebServiceJSONResponseAnABCUserPlayersForTeam["last_name"] as? String,
                let gamesplayed = abcWebServiceJSONResponseAnABCUserPlayersForTeam["gp"] as? Int,
                let goals = abcWebServiceJSONResponseAnABCUserPlayersForTeam["goals"] as? Int,
                let assists = abcWebServiceJSONResponseAnABCUserPlayersForTeam["assists"] as? Int,
                let total = abcWebServiceJSONResponseAnABCUserPlayersForTeam["total"] as? Int

                else {
                    // Exit gracefully if not getting the value for target key from the JSON object
                    print(#function + " Can't get sufficient data of the user-for-team")
                    return
            }

            // Set the value from the JSON object to the target object
            let anABCUserPlayerFromServerData = ABCPlayer(value: ["id":userPlayerID])
            anABCUserPlayerFromServerData.firstName = firstName
            anABCUserPlayerFromServerData.lastName = lastName
            anABCUserPlayerFromServerData.gamesPlayed.value = gamesplayed
            anABCUserPlayerFromServerData.goals.value = goals
            anABCUserPlayerFromServerData.assists.value = assists
            anABCUserPlayerFromServerData.totalGoalAndAssist.value = total
            anABCUserPlayerFromServerData.associatedTeamUUID = teamId

            ABCPlayerDataStore.sharedInstance.addOrUpdateAnABCPlayer(abcPlayer: anABCUserPlayerFromServerData)

            allABCPlayerUsersForTeamFromABCWebServiceToReturn.append(anABCUserPlayerFromServerData)

        }

        print(#function + " allABCPlayerUsersForTeamFromABCWebServiceToReturn are \(allABCPlayerUsersForTeamFromABCWebServiceToReturn.description)")

        return allABCPlayerUsersForTeamFromABCWebServiceToReturn

    }

    
    
}
