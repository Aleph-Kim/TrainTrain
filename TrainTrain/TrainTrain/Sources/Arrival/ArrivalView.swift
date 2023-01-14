import SwiftUI

struct ArrivalView: View {
  
  @Binding var selectedStationInfo: StationInfo
  @Binding var directionStationID: String
  @Binding var selectedSubwayLine: SubwayLine
  @Environment(\.scenePhase) var scenePhase
  @Environment(\.colorScheme) var colorScheme
  
  @State private var trainInfos: [TrainInfo] = []
  @State private var firstUpcomingTrainInfo: TrainInfo?
  @State private var secondUpcomingTrainInfo: TrainInfo?
  
  private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
  private let subwayClient: SubwayClient = .live()
  
  var body: some View {
    let subwayLineColor: Color = selectedSubwayLine.color(for: colorScheme)
    
    ZStack {
      backgroundView()
      
      VStack(spacing: 5) {
        HStack {
          subwayLineIndicatorCircle(lineColor: subwayLineColor)
          stationName()
          Spacer()
          nextStationIndicator()
        }
        .padding()
        .padding(.bottom, 5)
        
        ZStack {
          strokedLine()
          goalLineWithCircle()
          TrainProgressisStack(of: trainInfos)
        }
        .frame(height: 12)
        .padding(.horizontal)
        
        ZStack {
          secondaryBackgroundView()
          secondaryInformationView()
        }
      }
      .onAppear {
        fetchAll()
      }
      .onReceive(timer) { _ in
        fetchSome()
      }
      .onChange(of: directionStationID) { _ in
        fetchAll()
      }
      .onChange(of: scenePhase) { newScenePhase in
        switch newScenePhase {
        case .active: fetchAll()
        default: return
        }
      }
    }
  }
  
  private func backgroundView() -> some View {
    let roundedRectangleCornerRadius: CGFloat = 20.0
    
    return RoundedRectangle(cornerRadius: roundedRectangleCornerRadius)
      .foregroundColor(Color(uiColor: UIColor.secondarySystemBackground))
  }
  
  private func subwayLineIndicatorCircle(lineColor: Color) -> some View {
    let borderWidth: CGFloat = 4.0
    let frameSize: CGFloat = 28.0
    let subwayLinePrefix = selectedSubwayLine.name.prefix(1)
    
    return Circle()
      .strokeBorder(lineWidth: borderWidth)
      .frame(width: frameSize, height: frameSize)
      .foregroundColor(lineColor)
      .overlay {
        Text(subwayLinePrefix)
          .bold()
          .foregroundColor(.additionalGray(of: .additionalGray4, for: colorScheme))
      }
  }
  
  private func stationName() -> some View {
    Text(selectedStationInfo.stationName)
      .font(.title3)
      .bold()
      .foregroundColor(.additionalGray(of: .additionalGray4, for: colorScheme))
  }
  
  private func nextStationIndicator() -> some View {
    let spacing: CGFloat = 2.0
    let fontSize: CGFloat = 13.0
    let horizontalPadding: CGFloat = 4.0
    let verticalPadding: CGFloat = 2.0
    let backgroundCornerRadius: CGFloat = 2.0
    
    return  HStack(spacing: spacing) {
      Text("다음역")
        .font(.system(size: fontSize))
      Text(StationInfo.findStationName(from: directionStationID))
        .font(.system(size: fontSize))
        .bold()
    }
    .foregroundColor(.additionalGray(of: .additionalGray3, for: colorScheme))
    .padding(.horizontal, horizontalPadding)
    .padding(.vertical, verticalPadding)
    .background {
      RoundedRectangle(cornerRadius: backgroundCornerRadius)
        .foregroundColor(Color(uiColor: .systemGray5))
    }
  }
  
  private func strokedLine() -> some View {
    let lineWidth: CGFloat = 2.0
    let dash: [CGFloat] = [5.0]
    let dashPhase: CGFloat = 2.0
    let trailingPadding: CGFloat = 35.0
    let yOffset: CGFloat = 6.0
    
    return Line()
      .stroke(style: StrokeStyle(lineWidth: lineWidth, dash: dash, dashPhase: dashPhase))
      .foregroundColor(Color(uiColor: .systemGray5))
      .padding(.trailing, trailingPadding)
      .offset(y: yOffset)
  }
  
  private func goalLineWithCircle() -> some View {
    let hStackSpacing: CGFloat = 4.0
    let strokeBorderLineWidth: CGFloat = 3.0
    let frameSize: CGFloat = 16.0
    let yOffset: CGFloat = -2.0
    let lineWidth: CGFloat = 2.0
    let lineFrameWidth: CGFloat = 12.0
    let lineYOffset: CGFloat = 6.0
    
    return HStack(spacing: hStackSpacing) {
      Spacer()
      Circle()
        .strokeBorder(lineWidth: strokeBorderLineWidth)
        .frame(width: frameSize, height: frameSize)
        .offset(y: yOffset)
        .foregroundColor(.lineColor(subwayLine: selectedSubwayLine))
      Line()
        .stroke(style: StrokeStyle(lineWidth: lineWidth))
        .foregroundColor(Color(uiColor: .systemGray5))
        .frame(width: lineFrameWidth)
        .offset(y: lineYOffset)
    }
  }
  
  private func TrainProgressisStack(of trainInfos: [TrainInfo]) -> some View {
    let trailingPadding: CGFloat = 16.0
    
    return ForEach(trainInfos) { trainInfo in
      TrainProgressView(
        trainInfo: trainInfo,
        targetStation: selectedStationInfo,
        directionStationID: directionStationID,
        subwayLineColor: .lineColor(subwayLine: selectedSubwayLine)
      )
      .padding(.trailing, trailingPadding)
    }
  }
  
  private func secondaryBackgroundView() -> some View {
    let cornerRadius: CGFloat = 20.0
    
    return Rectangle()
      .cornerRadius(cornerRadius, corners: .bottomLeft)
      .cornerRadius(cornerRadius, corners: .bottomRight)
      .foregroundColor(Color(uiColor: .systemGray5))
  }
  
  private func secondaryInformationView() -> some View {
    VStack {
      if let firstUpcomingTrainInfo {
        HStack {
          Text("도착예정")
            .foregroundColor(.additionalGray(of: .additionalGray5, for: colorScheme))
          Text(Int(firstUpcomingTrainInfo.eta)!.asClock)
            .bold()
            .foregroundColor(.indigo)
          Text("후")
            .foregroundColor(.additionalGray(of: .additionalGray5, for: colorScheme))
        }
        .font(.title2)
      }
      HStack {
        if let secondUpcomingTrainInfo {
          Text("다음열차 약 \(Int(secondUpcomingTrainInfo.eta)!/60)분 후")
            .font(.subheadline)
            .foregroundColor(Color(uiColor: .systemGray))
        }
      }
    }
  }
  
  /// 실시간 열차의 배열에 새로운 열차를 append 하고, 떠난 열차는 remove 합니다.
  private func fetchSome() {
    Task {
      let newTrainInfos = try await subwayClient.fetchTrainInfos(
        targetStation: selectedStationInfo,
        directionStationID: directionStationID)
      
      // id 가 일치하는 열차가 없으면서, 그 열차의 secondMessage 가 타겟역이 아닌 경우에만
      // 기존 열차 배열에 새로운 열차를 추가함
      for newTrainInfo in newTrainInfos {
        if !trainInfos.contains(where: { $0.id == newTrainInfo.id || newTrainInfo.secondMessage == selectedStationInfo.stationName }) {
          trainInfos.append(newTrainInfo)
        }
      }
      
      // 기존 열차 배열에 존재했던 열차의 id 가, 새로운 열차 배열에서 사라졌다면
      // 기존 열차 배열에서 그 id 를 가진 열차를 삭제함 (이미 떠난 열차)
      for oldTrainInfo in trainInfos {
        if !newTrainInfos.contains(where: { $0.id == oldTrainInfo.id }) {
          trainInfos.removeAll(where: { $0.id == oldTrainInfo.id })
        }
      }
      
      // 전광판을 위한 State 업데이트
      firstUpcomingTrainInfo = newTrainInfos[safe: 0]
      secondUpcomingTrainInfo = newTrainInfos[safe: 1]
    }
  }
  
  /// 실시간 열차의 배열을 전부 새롭게 갱신합니다.
  private func fetchAll() {
    Task {
      trainInfos.removeAll()
      trainInfos = try await subwayClient.fetchTrainInfos(
        targetStation: selectedStationInfo,
        directionStationID: directionStationID)
      
      // 전광판을 위한 State 업데이트
      firstUpcomingTrainInfo = trainInfos[safe: 0]
      secondUpcomingTrainInfo = trainInfos[safe: 1]
    }
  }
}

struct ArrivalView_Previews: PreviewProvider {
  static var previews: some View {
    let gangNam = StationInfo.findStationInfo(from: "1002000222")
    
    ArrivalView(selectedStationInfo: .constant(gangNam), directionStationID: .constant("1002000221"), selectedSubwayLine: .constant(.line2))
  }
}
