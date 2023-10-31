//
//  Helper_LoadImage.swift
//  NoteStudyDemo
//
//  Created by Kathy on 31/10/2023.
//

import Foundation
import GoogleAPIClientForREST

import UIKit
class Helper_LoadImage {
    static let shared = Helper_LoadImage()
    let key = "AIzaSyDGgSCAOtnbiMwtklpJJ1VlacodhiM2E1c"
    let cx = "93c4fe5686c554061"
    func search(text: String){
        let service = GTLRService()
        let url = URL(string: "https://www.googleapis.com/customsearch/v1?q=\(text)&cx=\(cx)&tbm=isch")
                let query = GTLRQuery(pathURITemplate: "", httpMethod: nil, pathParameterNames: nil)
//        service.executeQuery(query) { ticket, object, error in
//            if let err = error {
//                print(err)
//                return
//            }
//        }
        service.fetchObject(with: URL(string:  "https://www.googleapis.com/customsearch/v1?q=\(text)&cx=\(cx)&tbm=isch&key=\(key)")!, objectClass: nil, executionParameters: nil) { ticket, object, error in
            if let err = error {
                print(err)
                return
            }
//            let item = GTLRDataObject(json: convertDictionaryToJSON(object as! [String : Any]))
            ticket.fetchedObject?.json
            ticket.
            let response = object as! GTLRObject
            print(ticket.fetchedObject?.json)
            
        }
              
        
        //        service.executeQuery(query) { [weak self] (ticket, object, error)  in
        //
        //            if let err = error {
        //                print(err)
        //                return
        //            }
        //            let response = object as! GTLRObject
        //
        //        }
        
    }
    func convertDictionaryToJSON(_ dictionary: [String: Any]) -> String? {

       guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
          print("Something is wrong while converting dictionary to JSON data.")
          return nil
       }

       guard let jsonString = String(data: jsonData, encoding: .utf8) else {
          print("Something is wrong while converting JSON data to JSON string.")
          return nil
       }

       return jsonString
    }
}
