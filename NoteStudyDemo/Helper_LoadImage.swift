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
    let searchType = "image"

    func search(text: String){
        let service = GTLRService()
        let url = URL(string:  "https://www.googleapis.com/customsearch/v1?q=\(text)&cx=\(cx)&searchType=\(searchType)&tbm=isch&key=\(key)")
        if let encodeQuery = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let urlString = url {
                let task = URLSession.shared.dataTask(with: urlString) { data, _, error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    do {
                        guard let data = data else { return }
                        let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let items = jsonData?["items"] as? [[String: Any]], let firstItem = items.first, let link = firstItem["link"] as? String, let imageURL = URL(string: link) {
                            print(url)
                        } else {
                            print("Image URL not found")
                        }
                        
                    } catch {
                        print(error.localizedDescription)

                    }
                }
                task.resume()
            }

        }
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
