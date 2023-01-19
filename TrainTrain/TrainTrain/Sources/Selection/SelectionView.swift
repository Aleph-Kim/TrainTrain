import SwiftUI
import ConfettiSwiftUI

struct SelectionView: View {

  enum SelectionStep: CaseIterable {
    case pre
    case lineNumber
    case station
    case direction

    static var maxIndex: Int {
      SelectionStep.allCases.count - 1
    }
  }

  private let stationInfoClient: StationInfoClient
  @Binding var selectedStation: StationInfo
  @Binding var directionStationID: String
  @Binding var selectedLine: SubwayLine
  @FocusState var isKeyboardUp: Bool
  
  @State private var selectionStep: SelectionStep = .pre
  @State private var stationList: [StationInfo] = []
  @State private var searchText = ""
  @State private var confetti: Int = .zero

  /// UserDefaults - 최초 설정 여부
  @AppStorage("firstSetting") private var firstSetting: Bool = true
  
  private let customAnimation: Animation = .linear(duration: 0.1)

  init(
    stationInfoClient: StationInfoClient,
    selectedStation: Binding<StationInfo>,
    directionStationID: Binding<String>,
    selectedLine: Binding<SubwayLine>,
    isKeyboardUp: FocusState<Bool>,
    selectionStep: SelectionStep = .pre,
    stationList: [StationInfo] = [],
    searchText: String = "",
    confetti: Int = .zero,
    firstSetting: Bool = true
  ) {
    self.stationInfoClient = stationInfoClient
    self._selectedStation = selectedStation
    self._directionStationID = directionStationID
    self._selectedLine = selectedLine
    self._isKeyboardUp = isKeyboardUp
    self.selectionStep = selectionStep
    self.stationList = stationList
    self.searchText = searchText
    self.confetti = confetti
    self.firstSetting = firstSetting
  }
  
  // MARK: - body
  var body: some View {
    VStack {
      TabView(selection: $selectionStep) {
        preSelectionPage()
          .tag(SelectionStep.pre)
          .highPriorityGesture(DragGesture())
        lineNumberSelectionPage()
          .tag(SelectionStep.lineNumber)
          .highPriorityGesture(DragGesture())
        stationSelectionPage()
          .tag(SelectionStep.station)
          .highPriorityGesture(DragGesture())
        directionSelectionPage()
          .tag(SelectionStep.direction)
          .highPriorityGesture(DragGesture())
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      
      // MARK: - 커스텀 페이지 인디케이터
      HStack(spacing: 10) {
        ForEach(SelectionStep.allCases.indices, id: \.self) { index in
          Circle()
            .fill(isCurrentPage(for: index) ? .secondary : .quaternary)
            .frame(width: 8, height: 8)
        }
      }
      .animation(nil, value: selectionStep)
    }
    .confettiCannon(
      counter: $confetti,
      rainHeight: 400,
      openingAngle: .degrees(45),
      closingAngle: .degrees(135),
      repetitions: 1)
    .onChange(of: directionStationID) { newDirectionStationID in
      // directionStationID 가 변경됐다면, 역과 방향에 대한 UserDefaults 를 모두 변경함
      UserDefaults.standard.set(selectedStation.stationID, forKey: "selectedStationID")
      UserDefaults.standard.set(newDirectionStationID, forKey: "directionStationID")
      UserDefaults.standard.set(false, forKey: "firstSetting")
    }
  }
  
  // MARK: - 선택해주세요 / 완료 페이지
  private func preSelectionPage() -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Spacer()
      
      if !firstSetting, let selectedLine = SubwayLine(rawValue: selectedStation.subwayLineID)! {
        let lineColor = selectedLine.color
        Text("완료됐습니다! 🎉\n이제 미리보기로\n확인해보세요.")
          .font(.title)
          .lineSpacing(6)
          .minimumScaleFactor(0.6)
        
        Spacer()
        
        VStack(alignment: .leading, spacing: 4) {
          Text(selectedLine.name)
            .colorCapsule(lineColor)
          
          HStack {
            Text(selectedStation.stationName)
              .colorCapsule(lineColor)
            
            Image(systemName: "arrow.right")
            
            Text(stationInfoClient.findStationName(from: directionStationID))
              .colorCapsule(lineColor)
          }
        }
      } else {
        Text("영차열차로\n확인하고 싶은 👀\n역을 선택해주세요.")
          .font(.title)
          .lineSpacing(6)
          .minimumScaleFactor(0.6)
      }
      
      Spacer()
      
      Button {
        withAnimation(customAnimation) {
          selectionStep = .pre
          selectionStep = .lineNumber
        }
      } label: {
        Text("선택 시작 →")
          .font(.title3)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
    }
    .padding(12)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .backgroundColor(.secondarySystemBackground)
    .cornerRadius(16)
    .padding(.horizontal)
  }
  
  // MARK: - 호선 선택 페이지
  private func lineNumberSelectionPage() -> some View {
    VStack(spacing: 10) {
      HStack {
        Text("몇 호선 인가요?")
          .askCapsule()
        Spacer()
        
        Button {
          withAnimation(customAnimation) {
            selectionStep = .lineNumber
            selectionStep = .pre
            isKeyboardUp = false // 키보드 내리기
          }
        } label: {
          Image(systemName: "arrow.uturn.left")
            .askCapsule(bold: false)
            .tint(.primary)
        }
        .buttonStyle(ReactiveButton())
      }
      
      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 20) {
          ForEach(SubwayLine.allCases) { line in
            Button {
              withAnimation(customAnimation) {
                selectedLine = line
                selectionStep = .lineNumber
                selectionStep = .station
                stationList = stationInfoClient.stationList(on: line)
              }
            } label: {
              HalfCapsule(line: line)
                .padding(.leading, 20)
            }
          }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .backgroundColor(.secondarySystemBackground)
      .cornerRadius(16)
    }
    .padding(.horizontal)
  }
  
  // MARK: - 역 선택 페이지
  private func stationSelectionPage() -> some View {
    VStack(spacing: 10) {
      HStack {
        if let selectedLine {
          let lineColor = selectedLine.color
          Text(selectedLine.name)
            .colorCapsule(lineColor)
        }
        
        Text("어느 역에서 탑승하세요?")
          .askCapsule()
        
        Spacer()
        
        Button {
          withAnimation(customAnimation) {
            selectionStep = .station
            selectionStep = .lineNumber
            isKeyboardUp = false // 키보드 내리기
          }
        } label: {
          Image(systemName: "arrow.uturn.left")
            .askCapsule(bold: false)
            .tint(.primary)
        }
        .buttonStyle(ReactiveButton())
      }
      
      VStack(spacing: .zero) {
        TextField("➡️ 탑승역 검색", text: $searchText)
          .textFieldStyle(.roundedBorder)
          .cornerRadius(10)
          .padding(.horizontal, 8)
          .padding(.top, 8)
          .submitLabel(.search)
          .focused($isKeyboardUp, equals: true)
        
        List(searchText.cleaned.isEmpty
             ? stationList
             : stationList.filter { $0.stationName.contains(searchText.cleaned) }
             , id: \.stationID) { station in
          Button {
            withAnimation(customAnimation) {
              selectedStation = station
              selectionStep = .station
              selectionStep = .direction
              searchText = ""
              isKeyboardUp = false // 키보드 내리기
            }
          } label: {
            HStack {
              Text(station.stationName)
              Spacer()
              Image(systemName: "chevron.right")
                .font(Font.body.weight(.light))
            }
          }
          .listRowInsets(.init(top: .zero, leading: 7, bottom: .zero, trailing: 16))
        }
        .listStyle(.plain)
        .cornerRadius(10)
        .padding(8)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(selectedLine.color)
      .cornerRadius(16)
    }
    .padding(.horizontal)
  }
  
  // MARK: - 방향 선택 페이지
  private func directionSelectionPage() -> some View {
    VStack(spacing: 10) {
      HStack {
        Text("어느 방향으로 가세요?")
          .askCapsule()
        Spacer()
        
        Button {
          withAnimation(customAnimation) {
            selectionStep = .direction
            selectionStep = .station
            isKeyboardUp = false // 키보드 내리기
          }
        } label: {
          Image(systemName: "arrow.uturn.left")
            .askCapsule(bold: false)
            .tint(.primary)
        }
        .buttonStyle(ReactiveButton())
      }
      
      VStack(spacing: 3) {
        HStack(spacing: 3) {
          // 상행선 1번
          if let upper1 = selectedStation.upperStationID_1 {
            Button {
              withAnimation(customAnimation) {
                directionStationID = upper1
                selectionStep = .direction
                selectionStep = .pre
                confetti += 1
              }
            } label: {
              Text(stationInfoClient.findStationName(from: upper1))
                .bold()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 10)
                .background(selectedLine.color)
                .cornerRadius(16)
            }
            .buttonStyle(ReactiveButton())
          } else {
            selectedLine.color
              .opacity(0.5)
              .cornerRadius(16)
          }
          
          // 하행선 1번
          if let lower1 = selectedStation.lowerStationID_1 {
            Button {
              withAnimation(customAnimation) {
                directionStationID = lower1
                selectionStep = .direction
                selectionStep = .pre
                confetti += 1
              }
            } label: {
              Text(stationInfoClient.findStationName(from: lower1))
                .bold()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 10)
                .background(selectedLine.color)
                .cornerRadius(16)
            }
            .buttonStyle(ReactiveButton())
          } else {
            selectedLine.color
              .opacity(0.5)
              .cornerRadius(16)
          }
        }
        
        // 상행선 2번 또는 하행선 2번 (둘 다 존재하는 케이스는 없음)
        Group {
          if let upper2 = selectedStation.upperStationID_2 {
            Button {
              withAnimation(customAnimation) {
                directionStationID = upper2
                selectionStep = .direction
                selectionStep = .pre
                confetti += 1
              }
            } label: {
              Text(stationInfoClient.findStationName(from: upper2))
                .bold()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(selectedLine.color)
                .cornerRadius(16)
            }
            .buttonStyle(ReactiveButton())
          } else if let lower2 = selectedStation.lowerStationID_2 {
            Button {
              withAnimation(customAnimation) {
                directionStationID = lower2
                selectionStep = .direction
                selectionStep = .pre
                confetti += 1
              }
            } label: {
              Text(stationInfoClient.findStationName(from: lower2))
                .bold()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 10)
                .background(selectedLine.color)
                .cornerRadius(16)
            }
            .buttonStyle(ReactiveButton())
          }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.15)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .font(.largeTitle)
      .foregroundColor(.white)
      .cornerRadius(16)
      .overlay(alignment: .top) {
        Text(selectedStation.stationName)
          .bold()
          .foregroundColor(.black)
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
          .background(.white)
          .clipShape(Capsule())
          .offset(y: 24)
      }
    }
    .padding(.horizontal)
  }
  
  // MARK: 커스텀 인디케이터를 위한 페이지 판단 메서드
  private func isCurrentPage(`for` index: Int) -> Bool {
    let safeIndex = index.clamped(to: 0...SelectionStep.maxIndex)
    return selectionStep == SelectionStep.allCases[safeIndex]
  }
}

// MARK: SwiftUI previews

struct SelectionView_Previews: PreviewProvider {
  static var previews: some View {
    SelectionView(
      stationInfoClient: .live(),
      selectedStation: .constant(
        StationInfo(
          subwayLineID: "1002",
          stationID: "1002000228",
          stationName: "서울대입구",
          lowerStationID_1: "1002000229",
          lowerStationETA_1: 60,
          lowerStationID_2: "",
          lowerStationETA_2: "",
          upperStationID_1: "1002000227",
          upperStationETA_1: 120,
          upperStationID_2: "",
          upperStationETA_2: "")),
      directionStationID: .constant("1002000227"),
      selectedLine: .constant(.line2),
      isKeyboardUp: FocusState<Bool>())
  }
}
