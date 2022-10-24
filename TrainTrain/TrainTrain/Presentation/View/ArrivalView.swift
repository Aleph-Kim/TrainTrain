////
////  ArrivalView.swift
////  TrainTrain
////
////  Created by daco daco on 2022/10/02.
////
//
//import SwiftUI
//
//struct ArrivalView: View {
//
//  @State private var trainInfos: [TrainInfo] = []
//
//  init(selectedStationInfo: StationInfo, directionStationID: String) {
//    let stations = selectedStationInfo.makeThreeStationList(stationInfo: selectedStationInfo, directionStationID: directionStationID)
//    targetStation = stations.0
//    prevStation = stations.1
//    prevPrevStation = stations.2
//  }
//
//
//  private var firstInfos: [TrainInfo] {
//    trainInfos.filter {
//      $0.previousStationID == targetStation.stationID
//    }
//  }
//  private var secondInfos: [TrainInfo] {
//    trainInfos.filter {
//      $0.previousStationID == prevStation?.stationID
//    }
//  }
//  private var thirdInfos: [TrainInfo] {
//    trainInfos.filter {
//      $0.previousStationID == prevPrevStation?.stationID
//    }
//  }
//
//  /// 타겟 역
//  private let targetStation: StationInfo
//  /// 전 역
//  private let prevStation: StationInfo?
//  /// 전전 역
//  private let prevPrevStation: StationInfo?
//
//  var body: some View {
//    ZStack {
//      RoundedRectangle(cornerRadius: 20)
//        .foregroundColor(.black)
//      GeometryReader { proxy in
//        VStack(spacing: 0) {
//          Spacer()
//          HStack {
//            TrackView(trainInfos: thirdInfos)
//              .frame(width: proxy.size.width / 3)
//            TrackView(trainInfos: secondInfos)
//              .frame(width: proxy.size.width / 3)
//            TrackView(trainInfos: firstInfos)
//              .frame(width: proxy.size.width / 3)
//          }
//          LineView(size: proxy.size)
//            .foregroundColor(.gray)
//            .offset(y: 5)
//        }
//      }
//    }
//    .onAppear {
//      let networkManager = NetworkManager()
//      var newTrainInfos: [TrainInfo] = []
//      Task {
//        newTrainInfos.append(contentsOf: await networkManager.fetch(targetStation: targetStation))
//        newTrainInfos.append(contentsOf: await networkManager.fetch(targetStation: prevStation))
//        newTrainInfos.append(contentsOf: await networkManager.fetch(targetStation: prevPrevStation))
//        trainInfos = newTrainInfos
//      }
//
//      Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
//        Task {
//          var newTrainInfos: [TrainInfo] = []
//          newTrainInfos.append(contentsOf: await networkManager.fetch(targetStation: targetStation))
//          newTrainInfos.append(contentsOf: await networkManager.fetch(targetStation: prevStation))
//          newTrainInfos.append(contentsOf: await networkManager.fetch(targetStation: prevPrevStation))
//
//          for trainInfo in trainInfos {
//            let _ = newTrainInfos.map { newTrainInfo in
//              if newTrainInfo.id == trainInfo.id {
//                if trainInfo.arrivalState != newTrainInfo.arrivalState {
//                  if let firstIndex = trainInfos.firstIndex(where: {newTrainInfo.id == $0.id}) {
//                    trainInfos[firstIndex] = newTrainInfo
//                  }
//                }
//              }
//            }
//          }
//
//          print(firstInfos)
//          print(secondInfos)
//          print(thirdInfos)
//        }
//      }
//    }
//  }
//
//  private func TrackView(trainInfos: [TrainInfo]) -> some View {
//    ZStack {
//      ForEach(trainInfos) { trainInfo in
//        TrainProgressView(arrivalState: trainInfo.arrivalState)
//          .foregroundColor(.white)
//      }
//      Spacer()
//    }
//  }
//
//  private func LineView(size: CGSize) -> some View {
//    Path { path in
//      path.move(to: CGPoint(x: 0, y: 0))
//      path.addLine(to: CGPoint(x: size.width - 20, y: 0))
//    }
//    .stroke(style: .init(lineWidth: 3, lineCap: .square, dash: [6]))
//  }
//}
//
//// MARK: SwiftUI previews
//
//struct ArrivalView_Previews: PreviewProvider {
//  static var previews: some View {
//    let stationInfo = StationInfo(
//      subwayLineID: "1002",
//      stationID: "1002000228",
//      stationName: "서울대입구",
//      nextStationName: "낙성대",
//      previousStationName: "봉천")
//    ArrivalView(selectedStationInfo: stationInfo)
//      .frame(height: 160)
//      .padding(.horizontal)
//  }
//}
