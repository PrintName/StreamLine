//
//  ViewController.swift
//  StreamLine
//
//  Created by Allen Li on 2/15/20.
//  Copyright © 2020 Allen Li. All rights reserved.
//

import UIKit
import Foundation
import DropDown
import PieCharts

class ViewController: UIViewController {
   
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var searchField: UITextField!
   @IBOutlet weak var searchFieldView: UIView!
   @IBOutlet weak var pieChartView: PieChart!
   @IBOutlet weak var pieChart2: PieChart!
   
   let highPriceSet = Set<String>(["Netflix", "Amazon Instant Video", "Amazon Prime Video"]) //
   
   var searchedShows = Shows()
   let searchMenu = DropDown()
   var pickedShows = Shows()
   var pickedShowSums: [String:Int] = [:]
   var pieChartResults = [PieSliceModel]()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      tableView.dataSource = self
      tableView.delegate = self
      searchMenu.anchorView = searchFieldView
      
      // Pick Show
      searchMenu.selectionAction = { [unowned self] (index: Int, item: String) in
         let show = self.searchedShows.showArray.filter{$0.name == item}[0]
         self.pickedShows.showArray.append(show)
         DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateSumsData()
            //self.drawPieChart(self.pieChartResults)
         }
      }
      
      pieChart2.models = [ PieSliceModel(value: 1, color: UIColor.init(red: 57/256, green: 57/256, blue: 63/256, alpha: 1), obj: "")]
   }
   @IBAction func jyhgjh(_ sender: Any) {
      self.updatePieChartResults()
   }
   
   @IBAction func searchAction(_ sender: Any) {
      
      let keywords = searchField.text!
      searchedShows.queryShows(keywords) {
         let showNamesArray = self.searchedShows.showArray.map{$0.name}
         self.searchMenu.dataSource = showNamesArray
         //print(self.searchedShows.showArray)
      }
      searchMenu.show()
   }
   
   func updateSumsData() {
      pickedShowSums = [:]
      for i in (0..<pickedShows.showArray.count) {
         for j in (0..<pickedShows.showArray[i].services.count) {
            let service = pickedShows.showArray[i].services[j]
            if pickedShowSums[service] == nil {
               pickedShowSums[service] = 1
            } else {
               pickedShowSums[service]! += 1
            }
         }
      }
   }
   
   func updatePieChartResults() {
      for (key,value) in pickedShowSums {
         print(key)
         print(value)
         pieChartResults.append(PieSliceModel(value: Double(value), color: UIColor.init(red: 57/256, green: 57/256, blue: 63/256, alpha: 1), obj: key))
      }
      drawPieChart(pieChartResults)
   }
   
   func drawPieChart(_ models: [PieSliceModel]) {
      print(models)
      pieChartView.models = models
      pieChartView.setNeedsDisplay()
      var textLayerSettings = PieLineTextLayerSettings()
      textLayerSettings.lineColor = UIColor.white
      textLayerSettings.label.textColor = UIColor.white
      textLayerSettings.label.font = UIFont.systemFont(ofSize: 10)
      textLayerSettings.label.textGenerator = {slice in
         return slice.data.model.obj as! String
      }
      let textLayer = PieLineTextLayer()
      textLayer.settings = textLayerSettings
      pieChartView.layers = [textLayer]
   }
   

   
}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return pickedShows.showArray.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let servicesCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ServicesTableViewCell
      servicesCell.titleLabel.text = pickedShows.showArray[indexPath.row].name
      servicesCell.tagListView.removeAllTags()
      servicesCell.tagListView.addTags(pickedShows.showArray[indexPath.row].services)
      return servicesCell
   }
   
}

