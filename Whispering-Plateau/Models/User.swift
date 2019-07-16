//
//  User.swift
//  Whispering-Plateau
//
//  Created by Ben Cootner on 7/9/19.
//  Copyright © 2019 Ben Cootner. All rights reserved.
//

import Foundation
class User: ModelObject {

    let userId: Int
    let firstName: String
    let lastName: String
    let office: String?

    let email: String?
    let experienceLevel: String?
    let judgeTier: String?
    let slackUsername: String?
    let createdAt: String?
    let updatedAt: String?
    let dciNumber: Int?
    let gamesPlayed: Int?
    let rating: Int?
    let pro: Bool?

    var name: String {
        return "\(firstName) \(lastName)"
    }




    /*
     {"id":1,"first_name":"Andrew","last_name":"Baber","email":"andrewb@grubhub.com","experience_level":"Play currently","judge_tier":null,"office":"Boston 1 Federal","slack_username":"@andrewb","created_at":"2019-06-28T23:15:10.864Z","updated_at":"2019-06-28T23:15:10.864Z","dci_number":null,"games_played":0,"rating":1000,"pro":false}
     */

    required init(dictionary: [String : Any]) {
        self.userId = dictionary["id"] as! Int
        self.firstName = dictionary["first_name"] as! String
        self.lastName = dictionary["last_name"] as! String

        self.office = dictionary["office"] as? String
        self.email = dictionary["email"] as? String
        self.experienceLevel = dictionary["experience_level"] as? String
        self.judgeTier = dictionary["judge_tier"] as? String
        self.slackUsername = dictionary["slack_username"] as? String
        self.createdAt = dictionary["created_at"] as? String
        self.updatedAt = dictionary["updated_at"] as? String
        self.dciNumber = dictionary["dci_number"] as? Int
        self.gamesPlayed = dictionary["games_played"] as? Int
        self.rating = dictionary["rating"] as? Int
        self.pro = dictionary["pro"] as? Bool

        super.init()
    }

    init(standing: Standing) {
        self.userId = standing.userId
        self.firstName = standing.firstName
        self.lastName = standing.lastName
        self.office = standing.office


        self.email = nil
        self.experienceLevel = nil
        self.judgeTier = nil
        self.slackUsername = nil
        self.createdAt = nil
        self.updatedAt = nil
        self.dciNumber = nil
        self.gamesPlayed = nil
        self.rating = nil
        self.pro = nil
        
        super.init()
    }
    

    // Request methods

    static let baseUrl =  "https://whispering-plateau-91662.herokuapp.com/api/users"

    class func getUsers(completion: @escaping ([User]) -> Void) {
        guard let url = URL(string: baseUrl) else {
            completion([])

            return
        }

        ModelObject.perfomRequest(withURL: url, modelClass: self.classForCoder(), success: { (modelObjects) in
            guard let modelObjects = modelObjects as? [User] else {
                completion([])

                return
            }

            completion(modelObjects)
        }) { (error) in
            completion([])
        }
    }
}
