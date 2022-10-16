//
//  ArrivalView.swift
//  TrainTrain
//
//  Created by daco daco on 2022/10/02.
//

import SwiftUI

struct ArrivalView: View {
    
    @State private var trainInfos: [TrainInfo] = []
    private var firstInfos: [TrainInfo] {
        trainInfos.filter {
            $0.previousStationID == "1002000229"
        }
    }
    private var secondInfos: [TrainInfo] {
        trainInfos.filter {
            $0.previousStationID == "1002000230"
        }
    }
    private var thirdInfos: [TrainInfo] {
        trainInfos.filter {
            $0.previousStationID == "1002000231"
        }
    }

    /// 2호선 서울대입구역
    private let dummy1 = StationInfo(
      subwayLineID: "1002",
      stationID: "1002000228",
      stationName: "서울대입구",
      nextStationName: "",
      previousStationName: "봉천")

    /// 2호선 봉천역
    private let dummy2 = StationInfo(
      subwayLineID: "1002",
      stationID: "1002000229",
      stationName: "봉천",
      nextStationName: "",
      previousStationName: "신림")

    /// 2호선 신림역
    private let dummy3 = StationInfo(
      subwayLineID: "1002",
      stationID: "1002000230",
      stationName: "신림",
      nextStationName: "",
      previousStationName: "신대방")
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.black)
                VStack(spacing: 0) {
                    Spacer()
                    HStack {
                        TrackView(trainInfos: thirdInfos)
                            .frame(width: proxy.size.width / 3)
                        TrackView(trainInfos: secondInfos)
                            .frame(width: proxy.size.width / 3)
                        TrackView(trainInfos: firstInfos)
                            .frame(width: proxy.size.width / 3)
                    }
                    LineView(size: proxy.size)
                        .foregroundColor(.gray)
                        .offset(CGSize(width: 0, height: 5))
                }
            }
        }
        .onAppear {
            let networkManager = NetworkManager()
            var newTrainInfos: [TrainInfo] = []
            Task {
                newTrainInfos.append(contentsOf: await networkManager.fetch(targetStation: dummy1, nextStationName: "낙성대"))
                newTrainInfos.append(contentsOf: await networkManager.fetch(targetStation: dummy2, nextStationName: "서울대입구"))
                newTrainInfos.append(contentsOf: await networkManager.fetch(targetStation: dummy3, nextStationName: "봉천"))
                trainInfos = newTrainInfos
            }
            
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                Task {
                    var newTrainInfos: [TrainInfo] = []
                    newTrainInfos.append(contentsOf: await networkManager.fetch(targetStation: dummy1, nextStationName: "낙성대"))
                    newTrainInfos.append(contentsOf: await networkManager.fetch(targetStation: dummy2, nextStationName: "서울대입구"))
                    newTrainInfos.append(contentsOf: await networkManager.fetch(targetStation: dummy3, nextStationName: "봉천"))
                    
                    for trainInfo in trainInfos {
                        let _ = newTrainInfos.map { newTrainInfo in
                            if newTrainInfo.id == trainInfo.id {
                                if trainInfo.arrivalCode != newTrainInfo.arrivalCode {
                                    if let firstIndex = trainInfos.firstIndex(where: {newTrainInfo.id == $0.id}) {
                                        trainInfos[firstIndex] = newTrainInfo
                                    }
                                }
                            }
                        }
                    }
                    
                    print(firstInfos)
                    print(secondInfos)
                    print(thirdInfos)
                }
            }
        }
    }
    
    private func TrackView(trainInfos: [TrainInfo]) -> some View {
        ZStack {
            ForEach(trainInfos) { trainInfo in
                TrainProgressView(arrivalCode: Int(trainInfo.arrivalCode) ?? 99)
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
    
    private func LineView(size: CGSize) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: 0))
        }
        .stroke(style: .init(lineWidth: 3, lineCap: .square, dash: [6]))
    }
}

struct ArrivalView_Previews: PreviewProvider {
    static var previews: some View {
        ArrivalView()
            .frame(height: 160)
            .padding(.horizontal)
    }
}
