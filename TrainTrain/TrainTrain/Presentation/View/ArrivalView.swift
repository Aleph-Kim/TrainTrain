import SwiftUI

struct ArrivalView: View {
  
  @State private var trainInfos: [TrainInfo] = []
  @State private var firstMessage_1: String = ""
  @State private var firstMessage_2: String = ""
  @Binding var selectedStationInfo: StationInfo
  @Binding var directionStationID: String
  private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
  
  private var targetStationTrainInfos: [TrainInfo] {
    trainInfos.filter {
      $0.arrivalState == .approaching ||
      $0.arrivalState == .arrived ||
      $0.arrivalState == .departed
    }
  }
  private var prevStationTrainInfos: [TrainInfo] {
    trainInfos.filter {
      $0.arrivalState == .previousApproaching ||
      $0.arrivalState == .previousArrived ||
      $0.arrivalState == .previousDeparted
    }
  }
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .foregroundColor(.black)
      GeometryReader { proxy in
        VStack(spacing: 0) {
          Spacer()
          HStack {
            TrackView(trainInfos: prevStationTrainInfos)
              .frame(width: proxy.size.width / 2)
            TrackView(trainInfos: targetStationTrainInfos)
              .frame(width: proxy.size.width / 2)
          }
          LineView(size: proxy.size)
            .foregroundColor(.gray)
            .offset(y: 5)
        }
      }
      GeometryReader { proxy in
        HStack {
          Rectangle()
            .frame(width: 5, height: 10)
            .foregroundColor(.white)
            .offset(x: proxy.size.width * 0.25 / 2, y:proxy.size.height / 2 + 10)
          Rectangle()
            .frame(width: 5, height: 10)
            .foregroundColor(.white)
            .offset(x: proxy.size.width * 1.25 / 2, y:proxy.size.height / 2 + 10)
        }
      }
      HStack {
        Spacer()
        VStack(alignment: .trailing) {
          Text(firstMessage_2)
            .font(.caption2)
          Text(firstMessage_1)
            .font(.caption)
          Spacer()
        }
        .padding(.top)
      }
      .padding(.horizontal)
      .foregroundColor(.white)
    }
    .onReceive(timer) { _ in
      let networkManager = NetworkManager()
      Task {
        // 한 번의 fetch로 진행
        trainInfos = await networkManager.fetch(targetStation: selectedStationInfo, directionStationID: directionStationID)
        print(trainInfos)
      }
      
      Task {
        let newTrainInfosOriginal = await networkManager.fetch(targetStation: selectedStationInfo, directionStationID: directionStationID)
        
        firstMessage_1 = newTrainInfosOriginal[0].firstMessage
        firstMessage_2 = newTrainInfosOriginal[1].firstMessage
        
        let newTrainInfos = newTrainInfosOriginal.filter { $0.arrivalState != .driving }
        
        for newTrainInfo in newTrainInfos {
          let _ = trainInfos.map { oldTrainInfo in
            // 만약 fetch시 기존 열차의 정보가 없다면, 이미 타겟 역을 지나간 경우이므로, 배열에서 삭제함
            if !newTrainInfos.contains(where: { $0.id == oldTrainInfo.id }) {
              if let firstIndex = trainInfos.firstIndex(where: { oldTrainInfo.id == $0.id }) {
                trainInfos.remove(at: firstIndex)
              }
            }
            
            if !trainInfos.contains(where: { $0.id == newTrainInfo.id }) {
              trainInfos.append(newTrainInfo)
            }
            
            guard oldTrainInfo.id == newTrainInfo.id else { return }
            
            if newTrainInfo.arrivalState != oldTrainInfo.arrivalState {
              if let firstIndex = trainInfos.firstIndex(where: { newTrainInfo.id == $0.id }) {
                trainInfos[firstIndex] = newTrainInfo
              }
            }
          }
        }
      }
    }
  }
  
  private func TrackView(trainInfos: [TrainInfo]) -> some View {
    ZStack {
      ForEach(trainInfos) { trainInfo in
        TrainProgressView(arrivalState: trainInfo.arrivalState, eta: Int(trainInfo.eta)!)
          .foregroundColor(.white)
      }
      Spacer()
    }
  }
  
  private func LineView(size: CGSize) -> some View {
    Path { path in
      path.move(to: CGPoint(x: 5, y: 0))
      path.addLine(to: CGPoint(x: size.width-10, y: 0))
    }
    .stroke(style: .init(lineWidth: 3, lineCap: .square, dash: [6]))
  }
}

// MARK: SwiftUI previews

//struct ArrivalView_Previews: PreviewProvider {
//  static var previews: some View {
//
//    let stationInfo = StationInfo(
//      subwayLineID: "1002",
//      stationID: "1002000222",
//      stationName: "강남",
//      lowerStationID_1: "1002000223",
//      lowerStationETA_1: 60,
//      lowerStationID_2: "",
//      lowerStationETA_2: "",
//      upperStationID_1: "1002000221",
//      upperStationETA_1: 60,
//      upperStationID_2: "",
//      upperStationETA_2: "")
//
//    ArrivalView(selectedStationInfo: stationInfo, directionStationID: stationInfo.lowerStationID_1!)
//      .frame(height: 160)
//      .padding(.horizontal)
//  }
//}
