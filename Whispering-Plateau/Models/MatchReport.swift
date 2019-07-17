//
//  MatchReport.swift
//  Whispering-Plateau
//
//  Created by Ben Cootner on 7/9/19.
//  Copyright © 2019 Ben Cootner. All rights reserved.
//

import Foundation
class MatchReport: ModelObject {
    let userId: Int // reporter
    let winnerId: Int
    let loserId: Int
    let gamesCount: Int
    let leagueId: Int

    required init(dictionary: [String : Any]) {
        self.userId = dictionary["id"] as! Int
        self.winnerId = dictionary["winner_id"] as! Int
        self.loserId = dictionary["loser_id"] as! Int
        self.gamesCount = dictionary["games_count"] as! Int
        self.leagueId = dictionary["league_id"] as! Int

        super.init()
    }

    init(winner: User, loser: User, gameCount: Int, leagugeId: Int) {
        self.userId = winner.userId
        self.winnerId = winner.userId
        self.loserId = loser.userId
        self.gamesCount = gameCount
        self.leagueId = leagugeId

        super.init()
    }

    var json: [String:[String: Any]] {
        var dict = [String: Any]()
        dict["user_id"] = self.userId
        dict["winner_id"] = self.winnerId
        dict["loser_id"] = self.loserId
        dict["games_count"] = self.gamesCount
        dict["league_id"] = self.leagueId
        return ["match_result" : dict]
    }

    let baseUrl = "https://api.mtg-league.com/api/match_results"

    /*

     {"match_result":{"user_id":1,"winner_id":1,"loser_id":23,"games_count":2,"league_id":3}}

     */

    func postMatchResult(completion: @escaping (Bool) -> Void) {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        let url = URL(string: baseUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(false)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
                completion(true)
            } else {
                completion(false)
            }
        }

        task.resume()
    }
}
