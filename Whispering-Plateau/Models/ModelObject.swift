//
//  ModelObject.swift
//  Whispering-Plateau
//
//  Created by Ben Cootner on 6/30/19.
//  Copyright © 2019 Ben Cootner. All rights reserved.
//

import Foundation

class ModelObject: NSObject {

    required init(dictionary: [String: Any]) {
        fatalError("Subclass must override this method")
    }

    func create(fromDictionary dictionary: [String: Any]) -> ModelObject {
        return ModelObject()
    }

    override init() {
        super.init()
    }


    class func perfomRequest(withURL url: URL, modelClass: AnyClass, success: @escaping (Any) -> Void, failure:  @escaping (Error?) -> Void) {

        guard let modelClass = modelClass as?  ModelObject.Type else {
            failure(nil)

            return
        }

        let request = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                guard let data = data else {
                    failure(nil)
                    return
                }

                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let objects = json as? [Any] {
                    var modelObjects = [ModelObject]()
                    for object in objects as! [[String: Any]] {
                        let modelObject = modelClass.init(dictionary: object)
                        modelObjects.append(modelObject)
                    }

                    success(modelObjects)
                    
                } else if let object = json as? [String: Any] {
                    let modelObject = modelClass.init(dictionary: object)
                    success(modelObject)
                } else {
                    failure(nil)
                }


            } catch {
                failure(nil)
            }
        }

        request.resume()
    }
}
