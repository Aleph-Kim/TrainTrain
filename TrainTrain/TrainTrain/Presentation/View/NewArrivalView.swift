import SwiftUI

struct NewArrivalView: View {

  @Binding var selectedStationInfo: StationInfo
  @Binding var directionStationID: String

  @State private var trainInfos: [TrainInfo] = []

  private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
  private let networkManager = NetworkManager()

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .foregroundColor(.black)

      Group {
        Capsule()
          .foregroundColor(.gray)
          .frame(height: 15)

        HStack {
          Circle()
            .frame(width: 15, height: 15)
            .foregroundColor(.white)

          Spacer()

          Circle()
            .frame(width: 15, height: 15)
            .foregroundColor(.white)
        }

        ForEach(trainInfos) { trainInfo in
          NewTrainProgressView(
            trainInfo: trainInfo,
            targetStation: selectedStationInfo,
            directionStationID: directionStationID)
        }
      }
      .offset(y: 30)
      .frame(height: 15)
      .padding(.horizontal)
      
      VStack {
        HStack {
          Text(selectedStationInfo.stationName + "역 도착정보")
            .bold()
            .foregroundColor(.white)
          Spacer()
        }
        .padding()
        Spacer()
      }
      
      VStack {
        HStack {
          Spacer()
          firstUpcomingTrain
        }
        .padding([.horizontal, .top])
        
        HStack() {
          Spacer()
          secondUpcomingTrain
        }
        .padding(.horizontal)
        
        Spacer()
      }

    }
    .onReceive(timer) { _ in
      fetchSome()
    }
    .onChange(of: directionStationID) { _ in
      trainInfos.removeAll()
      fetchAll()
    }
    .onAppear {
      fetchAll()
    }
  }
  
  private func fetchSome() {
    Task {
      let newTrainInfos = await networkManager.fetch(
        targetStation: selectedStationInfo,
        directionStationID: directionStationID)
      
      for newTrainInfo in newTrainInfos {
        if !trainInfos.contains(where: { $0.id == newTrainInfo.id || newTrainInfo.secondMessage == selectedStationInfo.stationName }) {
          trainInfos.append(newTrainInfo)
        }
      }
      
      for oldTrainInfo in trainInfos {
        if !newTrainInfos.contains(where: {$0.id == oldTrainInfo.id}) {
          trainInfos.removeAll(where: {$0.id == oldTrainInfo.id})
        }
      }
    }
  }
  
  private func fetchAll() {
    Task {
      trainInfos = await networkManager.fetch(
        targetStation: selectedStationInfo,
        directionStationID: directionStationID)
    }
  }

  private var firstUpcomingTrain: some View {
    var message = "이번 열차: "

    if let firstUpcoming = trainInfos[safe: 0] {
      if firstUpcoming.secondMessage == selectedStationInfo.stationName {
        // 타겟역에 진입 중이거나 도착한 열차라면 (ETA 는 이 시점에서 무의미함)
        message.append(firstUpcoming.firstMessage.contains("도착") ? "도착" : "곧 도착")
      } else {
        // 적당히 멀리있는 열차라면 (ETA 중요)
        message.append(firstUpcoming.eta.asApproximateClock)
      }
    } else {
      message.append("정보 없음")
    }

    return Text(message)
      .font(.caption)
      .foregroundColor(.white)
  }

  private var secondUpcomingTrain: some View {
    var message = "다음 열차: "

    if let secondUpcoming = trainInfos[safe: 1] {
      if secondUpcoming.secondMessage == selectedStationInfo.stationName {
        // 타겟역에 진입 중이거나 도착한 열차라면 (ETA 는 이 시점에서 무의미함)
        message.append(secondUpcoming.firstMessage.contains("도착") ? "도착" : "곧 도착")
      } else {
        // 적당히 멀리있는 열차라면 (ETA 중요)
        message.append(secondUpcoming.eta.asApproximateClock)
      }
    } else {
      message.append("정보 없음")
    }

    return Text(message)
      .font(.caption2)
      .foregroundColor(.white)
      .opacity(0.8)
  }
}

struct NewArrivalView_Previews: PreviewProvider {
  static var previews: some View {
    let gangNam = StationInfo.findStationInfo(from: "1002000222")

    NewArrivalView(selectedStationInfo: .constant(gangNam), directionStationID: .constant("1002000221"))
  }
}
