//
//  TrainTrainApp.swift
//  TrainTrain
//
//  Created by coda on 2022/09/11.
//

import SwiftUI

@main
struct TrainTrainApp: App {
  /// MARK: UserDefaults - 강남역의 ID 로 시작
   @AppStorage("selectedStationID") private var selectedStationID: String = "1002000222"

   /// MARK: UseDefaults - 역삼역의 ID 로 시작
   @AppStorage("directionStationID") private var directionStationID: String = "1002000221"

   var body: some Scene {
     WindowGroup {
       ContentView(
         selectedStationID: selectedStationID,
         directionStationID: directionStationID)
     }
   }
}
