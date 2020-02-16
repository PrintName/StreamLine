//
//  Shows.swift
//  StreamLine
//
//  Created by Allen Li on 2/15/20.
//  Copyright © 2020 Allen Li. All rights reserved.
//

import Alamofire
import SwiftyJSON

class Shows {
    
    var showArray: [ShowData] = []
    
    func queryShows(_ keywords: String, completed: @escaping ()->()) {
       showArray = []
       let headers = [
                "x-rapidapi-host": "utelly-tv-shows-and-movies-availability-v1.p.rapidapi.com",
                "x-rapidapi-key": "f814c51621msh659835cdc4673f6p1905e6jsnc6afea939ef7"
             ]
       let url = "https://utelly-tv-shows-and-movies-availability-v1.p.rapidapi.com/lookup"
       let query = ["term":keywords, "country":"us"]
        Alamofire.request(url, parameters: query, headers: headers).responseJSON { response in
          switch response.result {
          case .success(let response):
             let json = JSON(response)
             let numOfShows = json["results"].count
             var serviceResults: [String] = []
             for i in (0..<numOfShows){
                let showName = json["results"][i]["name"].stringValue
                let numOfServices = json["results"][i]["locations"].count
                for j in (0..<numOfServices){
                   serviceResults.append(json["results"][i]["locations"][j]["display_name"].stringValue)
                }
                let filteredServiceResults = Array(Set(serviceResults)) // Remove Duplicates
                self.showArray.append(ShowData(name: showName, services: filteredServiceResults))
             }
          case .failure(let error):
             print(error.localizedDescription)
          }
          completed()
       }
    }
    
}
