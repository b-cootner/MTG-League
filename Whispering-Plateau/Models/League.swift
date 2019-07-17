//
//  League.swift
//  Whispering-Plateau
//
//  Created by Ben Cootner on 7/9/19.
//  Copyright © 2019 Ben Cootner. All rights reserved.
//

import Foundation

@objc(League)
class League: ModelObject {
    let leagueId: Int
    let name: String
    let abbreviation: String
    let createdAt: String
    let updatedAt: String
    let active: Bool
    let users: [User]

    /*
     {"id":7,"name":"War of the Spark","set_abbreviation":"WAR","created_at":"2019-06-28T23:15:12.559Z","updated_at":"2019-06-28T23:15:12.559Z","active":true,"users":[]}
     */

    required init(dictionary: [String : Any]) {
        self.leagueId = dictionary["id"] as! Int
        self.name = dictionary["name"] as! String
        self.abbreviation = dictionary["set_abbreviation"] as! String
        self.createdAt = dictionary["created_at"] as! String
        self.updatedAt = dictionary["updated_at"] as! String
        self.active = dictionary["active"] as! Bool

        if let dictionaryOfUsers = dictionary["users"] as? [[String: Any]] {
            self.users = dictionaryOfUsers.map { (userDictionary) -> User in
                return User(dictionary: userDictionary)
            }
        } else {
            self.users = []
        }
        
        super.init()
    }

    static let baseUrl =  "https://api.mtg-league.com/api/leagues"

    class func getLeagueInfo(forLeagueId league: Int, completion: @escaping (League?) -> Void) {
        guard let url = URL(string: String(format: "\(baseUrl)/%@", String(league))) else {
            completion(nil)

            return
        }

        ModelObject.perfomRequest(withURL: url, modelClass: self.classForCoder(), success: { (modelObjects) in
            guard let modelObject = modelObjects as? League else {
                completion(nil)

                return
            }

            completion(modelObject)
        }) { (error) in
            completion(nil)
        }
    }

    class func getLeagues(completion: @escaping ([League]) -> Void) {
        guard let url = URL(string: baseUrl) else {
            completion([])

            return
        }

        ModelObject.perfomRequest(withURL: url, modelClass: self.classForCoder(), success: { (modelObjects) in
            guard let modelObject = modelObjects as? [League] else {
                completion([])

                return
            }

            completion(modelObject)
        }) { (error) in
            completion([])
        }
    }
}
