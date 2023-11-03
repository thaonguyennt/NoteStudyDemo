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
    let cx = "87c00997566d44195"
    let searchType = "image"
    let group = DispatchGroup()
    
    
    func search(text: String, completed: @escaping (([String]?) -> ())) {
        var listImages: [String] = []
        let service = GTLRService()
        let textConvert = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string:  "https://www.googleapis.com/customsearch/v1?q=\(textConvert)&cx=\(cx)&searchType=\(searchType)&tbm=isch&key=\(key)")!
        self.group.enter()
        service.fetchObject(with: url, objectClass: nil, executionParameters: nil) { [weak self] (ticket, object, error) in
            if let error = error {
                print("ERROR: \(error)")
            }
            let data = object as! GTLRObject
            let jsonData = data.json
            if let items = jsonData?["items"] as? [[String: Any]] {
                items.forEach { item in
                    if let link = item["link"] as? String {
                        listImages.append(link)
                    }
                }
                self?.group.leave()
            }
            else {
                self?.group.leave()
            }
        }
        group.notify(queue: .main) {
            completed(listImages)
        }
    }
}
