//
//  Standings.swift
//  Whispering-Plateau
//
//  Created by Ben Cootner on 6/28/19.
//  Copyright © 2019 Ben Cootner. All rights reserved.
//

import Foundation
class Standing: ModelObject {

    let userId: Int
    let firstName: String
    let lastName: String
    let office: String
    let overallRecord: String
    let week1Record: String
    let week2Record: String
    let week3Record: String
    let week4Record: String
    let ranking: String

    /*
     "user_id":57,"first_name":"Chris","last_name":"Curtis","office":"Tulsa","overall_record":"11-1","overall_points":23,"week1_record":"2-1","week2_record":"3-0","week3_record":"3-0","week4_record":"3-0","ranking":"1st"}
     */

    required init(dictionary: [String : Any]) {
        self.userId = dictionary["user_id"] as! Int
        self.firstName = dictionary["first_name"] as! String
        self.lastName = dictionary["last_name"] as! String
        self.office = dictionary["office"] as! String
        self.overallRecord = dictionary["overall_record"] as! String
        self.week1Record = dictionary["week1_record"] as! String
        self.week2Record = dictionary["week2_record"] as! String
        self.week3Record = dictionary["week3_record"] as! String
        self.week4Record = dictionary["week4_record"] as! String
        self.ranking = dictionary["ranking"] as! String

        super.init()
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    // Request methods

    static let baseUrl =  "https://api.mtg-league.com/api/leagues/%@/standings"

    class func getStandings(forLeague league: Int, completion: @escaping ([Standing]) -> Void) {
        guard let url = URL(string: String(format: baseUrl, String(league))) else {
            completion([])

            return
        }

        ModelObject.perfomRequest(withURL: url, modelClass: self.classForCoder(), success: { (modelObjects) in
            guard let modelObjects = modelObjects as? [Standing] else {
                completion([])

                return
            }

            completion(modelObjects)
        }) { (error) in
            completion([])
        }
    }
}
