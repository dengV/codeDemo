//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.


import Foundation
import Alamofire

public enum ABCWebServiceRouter: URLRequestConvertible {

    // Static keys to access the Web service
    static let authInstanceBaseURLPath = "https://api.abc.com:5500"
    static let apiInstanceBaseURLPath = "https://api.acb.com:5600"

    // Use Swift Enum with the associate values for efficient HTTP endpoint generating & data transmitting
    case userAccountNameAndPassword((String, String))
    case abcUser((String,String))
    case abcUsersForTeam((String,String,String))
    case abcPositionsForDivision((userAuthId:String, userAuthToken:String, divisionId:String))
    case abcDivisionsForLeague((String,String,String))
    case abcTeamsForDivision((String,String,String))
    case abcLeague((String,String,String))
    case abcSeasonsForDivision((String,String,String))
    case abcGame((String,String,String))
    case abcGamesForTeamAndMonth((String,String,String,String,String))
    case abcGamesForLeagueAndMonth((String,String,String,String,String))
    case abcUpdateForGame((userAuthId: String,userAuthToken: String, gameId:String, periodId:String, authorId: String, awayMod: String?, homeMod: String?, goalPlayerNo1Id:String?,assistPlayerNo2Id: String?, assistPlayerNo3Id: String?, minute: Int?, second:Int?, eventTime: String?, commentInfo: String?))
    case deleteScoringUpdate((userAuthId:String, userAuthToken:String, scoringUpdateId:String))

    // get the base url by Enum case
    var baseURLPath: String {
        switch self {
        case .userAccountNameAndPassword(_, _):
            return ABCWebServiceRouter.authInstanceBaseURLPath
        default:
            return ABCWebServiceRouter.apiInstanceBaseURLPath
        }
    }

    // get the HTTP method by Enum case
    var method: HTTPMethod {
        switch self {
        case .userAccountNameAndPassword(_, _):
            return .put
        case .abcUpdateForGame:
            return .post
        case .deleteScoringUpdate:
            return .delete
        default:
            return .get
        }
    }

    // get the endpoint by Enum case
    var path: String {
        switch self {
        case .userAccountNameAndPassword(_, _):
            return "/login"
        case .abcUser:
            return "/user"
        case .abcUsersForTeam:
            return "/team-users"
        case .abcPositionsForDivision:
            return "/division-players"
        case .abcDivisionsForLeague:
            return "/league-divisions"
        case .abcTeamsForDivision:
            return "/division-teams"
        case .abcLeague:
            return "/league"
        case .abcSeasonsForDivision:
            return "/division-seasons"
        case .abcGame:
            return "/game"
        case .abcGamesForTeamAndMonth:
            return "/team-and-month-games"
        case .abcGamesForLeagueAndMonth:
            return "/league-and-month-games"
        case .abcUpdateForGame:
            return "/update-game"
        case .deleteScoringUpdate:
            return "/remove-update"
        }
    }

    // get the header by Enum case
    var headers: [String:String]? {

        func getDefaultGeneratedHeaders(withUserIDAleadyInStore userIDAleadyInStore: String, AndUserAuthTokenAleadyInStore userAuthTokenAleadyInStore:String) -> [String:String]? {
            guard let encodedABCWebServerAuthorizationToken = ABCWebServiceRouter.getEncodedABCWebServerAuthorizationToken(fromUserID: userIDAleadyInStore, andAuthToken: userAuthTokenAleadyInStore) else {
                print(#function + " Can't get encodedABCWebServerAuthorizationToken when generating request headers")
                return nil
            }
            return ["Authorization":"Basic " + encodedABCWebServerAuthorizationToken]
        }

        switch self {
        case .userAccountNameAndPassword(_, _):
            return nil

        case .abcUser(let userIDAleadyInStore, let userAuthTokenAleadyInStore):
            return getDefaultGeneratedHeaders(withUserIDAleadyInStore: userIDAleadyInStore, AndUserAuthTokenAleadyInStore: userAuthTokenAleadyInStore)
        case .abcUsersForTeam(let userIDAleadyInStore, let userAuthTokenAleadyInStore,_):
            return getDefaultGeneratedHeaders(withUserIDAleadyInStore: userIDAleadyInStore, AndUserAuthTokenAleadyInStore: userAuthTokenAleadyInStore)
        case .abcPositionsForDivision(let userAuthId, let userAuthToken, _):
            return getDefaultGeneratedHeaders(withUserIDAleadyInStore: userAuthId, AndUserAuthTokenAleadyInStore: userAuthToken)
        case .abcDivisionsForLeague(let userIDAleadyInStore, let userAuthTokenAleadyInStore,_):
            return getDefaultGeneratedHeaders(withUserIDAleadyInStore: userIDAleadyInStore, AndUserAuthTokenAleadyInStore: userAuthTokenAleadyInStore)
        case .abcTeamsForDivision(let userIDAleadyInStore, let userAuthTokenAleadyInStore,_):
            return getDefaultGeneratedHeaders(withUserIDAleadyInStore: userIDAleadyInStore, AndUserAuthTokenAleadyInStore: userAuthTokenAleadyInStore)
        case .abcLeague(let userIDAleadyInStore, let userAuthTokenAleadyInStore,_):
            return getDefaultGeneratedHeaders(withUserIDAleadyInStore: userIDAleadyInStore, AndUserAuthTokenAleadyInStore: userAuthTokenAleadyInStore)
        case .abcSeasonsForDivision(let userIDAleadyInStore, let userAuthTokenAleadyInStore,_):
            return getDefaultGeneratedHeaders(withUserIDAleadyInStore: userIDAleadyInStore, AndUserAuthTokenAleadyInStore: userAuthTokenAleadyInStore)
        case .abcGame(let userIDAleadyInStore, let userAuthTokenAleadyInStore,_):
            return getDefaultGeneratedHeaders(withUserIDAleadyInStore: userIDAleadyInStore, AndUserAuthTokenAleadyInStore: userAuthTokenAleadyInStore)
        case .abcGamesForTeamAndMonth(let userIDAleadyInStore, let userAuthTokenAleadyInStore,_,_,_):
            return getDefaultGeneratedHeaders(withUserIDAleadyInStore: userIDAleadyInStore, AndUserAuthTokenAleadyInStore: userAuthTokenAleadyInStore)
        case .abcGamesForLeagueAndMonth(let userIDAleadyInStore, let userAuthTokenAleadyInStore,_,_,_):
            return getDefaultGeneratedHeaders(withUserIDAleadyInStore: userIDAleadyInStore, AndUserAuthTokenAleadyInStore: userAuthTokenAleadyInStore)
        case .abcUpdateForGame(let userIDAleadyInStore, let userAuthTokenAleadyInStore,_,_,_,_,_,_,_,_,_,_,_,_):
            return getDefaultGeneratedHeaders(withUserIDAleadyInStore: userIDAleadyInStore, AndUserAuthTokenAleadyInStore: userAuthTokenAleadyInStore)
        case .deleteScoringUpdate(let userIDAleadyInStore, let userAuthTokenAleadyInStore,_):
            return getDefaultGeneratedHeaders(withUserIDAleadyInStore: userIDAleadyInStore, AndUserAuthTokenAleadyInStore: userAuthTokenAleadyInStore)
        }
    }

    // get the parameter by Enum case
    var parameters: [String: Any]? {

        // Local methods of reusing code for clarity and efficency
        func getDefaultGeneratedParameters(WithIDAleadyInStore idAleadyInStore: String) -> [String:String] {
            return ["uuid":idAleadyInStore]
        }
        func getGamesForIdAndMonthGeneratedParameteres(id:String, targetYearOfABCGames: String, targetMonthOfABCGame: String) -> [String: String] {
            return ["uuid":id,"year":targetYearOfABCGames, "month": targetMonthOfABCGame]
        }
        func getUpdateForGameGeneratedParameteres(gameId:String, periodId:String, authorId: String, awayMod: String?, homeMod: String?, goalPlayerNo1Id:String?,assistPlayerNo2Id: String?, assistPlayerNo3Id: String?, minute: Int?, second: Int?, eventTime: String?, commentInfo: String?) -> [String:Any] {

            var parametersToReturn:[String: Any] = ["game_uuid":gameId,"period_uuid": periodId, "author_uuid":authorId]

            if let validAwayMod = awayMod { parametersToReturn["away_mod"] = validAwayMod } else { parametersToReturn["away_mod"] = "" }
            if let validHomeMod = homeMod { parametersToReturn["home_mod"] = validHomeMod } else { parametersToReturn["home_mod"] = "" }
            if let validGoalPlayerNo1Id = goalPlayerNo1Id { parametersToReturn["position_1_uuid"] = validGoalPlayerNo1Id } else { parametersToReturn["position_1_uuid"] = "" }
            if let validAssistPlayerNo2Id = assistPlayerNo2Id { parametersToReturn["position_2_uuid"] = validAssistPlayerNo2Id } else { parametersToReturn["position_2_uuid"] = "" }
            if let validAssistPlayerNo3Id = assistPlayerNo3Id { parametersToReturn["position_3_uuid"] = validAssistPlayerNo3Id } else { parametersToReturn["position_3_uuid"] = "" }
            if let validMinute = minute { parametersToReturn["minute"] = Int8(validMinute) }
            if let validSecond = second { parametersToReturn["second"] = Int8(validSecond) }
            if let validEventTime = eventTime { parametersToReturn["event_time"] = validEventTime } else { parametersToReturn["event_time"] = "" }
            if let validCommentInfo = commentInfo { parametersToReturn["info"] = validCommentInfo } else { parametersToReturn["info"] = "" }

            return parametersToReturn
        }

        switch self {
        case .userAccountNameAndPassword(let targetUserAccountname, let targetPassword):
            return ["username": targetUserAccountname, "password": targetPassword]
        case .abcUser(let userIDAleadyInStore, _):
            return getDefaultGeneratedParameters(WithIDAleadyInStore: userIDAleadyInStore)
        case .abcUsersForTeam(_, _, let targetABCUserPlayerAssociateTeamIDInStore):
            return getDefaultGeneratedParameters(WithIDAleadyInStore: targetABCUserPlayerAssociateTeamIDInStore)
        case .abcPositionsForDivision(_, _, let targetDivisionID):
            return getDefaultGeneratedParameters(WithIDAleadyInStore: targetDivisionID)
        case .abcDivisionsForLeague(_, _, let targetABCUserPlayerAssociateLeagueIDInStore):
            return getDefaultGeneratedParameters(WithIDAleadyInStore: targetABCUserPlayerAssociateLeagueIDInStore)
        case .abcTeamsForDivision(_, _, let targetABCDivisionID):
            return getDefaultGeneratedParameters(WithIDAleadyInStore: targetABCDivisionID)
        case .abcLeague(_, _, let targetABCUserPlayerAssociateLeagueIDInStore):
            return getDefaultGeneratedParameters(WithIDAleadyInStore: targetABCUserPlayerAssociateLeagueIDInStore)
        case .abcSeasonsForDivision(_, _, let targetABCDivisionID):
            return getDefaultGeneratedParameters(WithIDAleadyInStore: targetABCDivisionID)
        case .abcGame(_, _, let targetABCGameID):
            return getDefaultGeneratedParameters(WithIDAleadyInStore: targetABCGameID)
        case .abcGamesForTeamAndMonth(_, _, let teamID, let targetYearOfABCGames, let targetMonthOfABCGame):
            return getGamesForIdAndMonthGeneratedParameteres(id: teamID, targetYearOfABCGames: targetYearOfABCGames, targetMonthOfABCGame: targetMonthOfABCGame)
        case .abcGamesForLeagueAndMonth(_, _, let leagueID, let targetYearOfABCGames, let targetMonthOfABCGame):
            return getGamesForIdAndMonthGeneratedParameteres(id: leagueID, targetYearOfABCGames: targetYearOfABCGames, targetMonthOfABCGame: targetMonthOfABCGame)
        case .abcUpdateForGame(_,_, let gameId, let periodId, let authorId, let awayMod, let homeMod, let goalPlayerNo1Id, let assistPlayerNo2Id, let assistPlayerNo3Id, let minute, let second, let eventTime, let commentInfo):
            return getUpdateForGameGeneratedParameteres(gameId: gameId, periodId: periodId, authorId: authorId, awayMod: awayMod, homeMod: homeMod, goalPlayerNo1Id: goalPlayerNo1Id, assistPlayerNo2Id: assistPlayerNo2Id, assistPlayerNo3Id: assistPlayerNo3Id, minute: minute, second: second, eventTime: eventTime, commentInfo: commentInfo)
        case .deleteScoringUpdate(_,_,let scoringUpdateId):
            return getDefaultGeneratedParameters(WithIDAleadyInStore: scoringUpdateId)
        }

    }

    public func asURLRequest() throws -> URLRequest {

        let url = try self.baseURLPath.asURL()

        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        headers?.forEach({ (key, value) in
            request.addValue(value, forHTTPHeaderField: key)
        })
        request.timeoutInterval = TimeInterval(10 * 1000)
        return try JSONEncoding.default.encode(request, with: parameters)

    }

    static func getEncodedABCWebServerAuthorizationToken(fromUserID userID: String, andAuthToken authToken: String) -> String? {
        let abcWebServerAuthorizationTokenToBeEncoded = userID + ":" + authToken
        guard let abcEncodedWebServerAuthorizationTokenToReturn = abcWebServerAuthorizationTokenToBeEncoded.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions()) else {
            print(#function + " Can't get Encoded abcWebServerAuthorizationTokenToReturn")
            return nil
        }
        return abcEncodedWebServerAuthorizationTokenToReturn
    }
}
