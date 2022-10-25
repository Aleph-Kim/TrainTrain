import SwiftUI
import ConfettiSwiftUI

struct SelectionView: View {

  @Binding var selectedStation: StationInfo?
  @Binding var directionStationID: String?

  @State private var selectionStep: SelectionStep = .pre
  @State private var selectedLine: SubwayLine?
  @State private var stationList: [StationInfo] = []
  @State private var searchText = ""
  @State private var confetti: Int = .zero

  @FocusState private var isKeyboardUp: Bool?

  private let customAnimation: Animation = .linear(duration: 0.1)

  // MARK: - body
  var body: some View {
    VStack {
      TabView(selection: $selectionStep) {
        preSelectionPage
          .tag(SelectionStep.pre)
          .highPriorityGesture(DragGesture())
        lineNumberSelectionPage
          .tag(SelectionStep.lineNumber)
          .highPriorityGesture(DragGesture())
        stationSelectionPage
          .tag(SelectionStep.station)
          .highPriorityGesture(DragGesture())
        directionSelectionPage
          .tag(SelectionStep.direction)
          .highPriorityGesture(DragGesture())
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .frame(height: UIScreen.main.bounds.height * 0.4) // 화면 높이의 40% 사용

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
  }

  // MARK: - 선택해주세요 / 완료 페이지
  private var preSelectionPage: some View {
    VStack(alignment: .leading, spacing: 10) {
      Spacer()

      if let selectedLine, let selectedStation, let directionStationID {
        Text("완료됐습니다! 🎉\n이제 미리보기로\n확인해보세요.")
          .font(.title)
          .lineSpacing(6)
          .minimumScaleFactor(0.6)

        Spacer()

        VStack(alignment: .leading, spacing: 4) {
          Text(selectedLine.rawValue)
            .colorCapsule(selectedLine.color)

          HStack {
            Text(selectedStation.stationName)
              .colorCapsule(selectedLine.color)

            Image(systemName: "arrow.right")

            Text(StationInfo.fetchStationName(from: directionStationID))
              .colorCapsule(selectedLine.color)
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
          selectionStep = .lineNumber
        }
      } label: {
        Text(selectedStation == nil ? "선택 시작 →" : "다시 선택하기 →")
          .font(.title3)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
    }
    .padding(12)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.bg)
    .cornerRadius(16)
    .padding(.horizontal)
  }

  // MARK: - 호선 선택 페이지
  private var lineNumberSelectionPage: some View {
    VStack(spacing: 10) {
      HStack {
        Text("몇 호선 인가요?")
          .askCapsule()
        Spacer()
      }

      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 20) {
          ForEach(SubwayLine.allCases) { line in
            Button {
              withAnimation(customAnimation) {
                selectedLine = line
                selectionStep = .station
                stationList = StationInfo.fetchStationList(of: line)
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
      .background(Color.bg)
      .cornerRadius(16)
    }
    .padding(.horizontal)
  }

  // MARK: - 역 선택 페이지
  private var stationSelectionPage: some View {
    VStack(spacing: 10) {
      HStack {
        if let selectedLine {
          Text(selectedLine.rawValue)
            .colorCapsule(selectedLine.color)
        }

        Text("어느 역에서 탑승하시나요?")
          .askCapsule()

        Spacer()
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
              selectionStep = .direction
              searchText = ""
              isKeyboardUp = nil // 키보드 내리기
            }
          } label: {
            HStack {
              Text(station.stationName)
              Spacer()
              Image(systemName: "chevron.right")
                .fontWeight(.light)
            }
          }
          .listRowInsets(.init(top: .zero, leading: 7, bottom: .zero, trailing: 16))
          .listRowBackground(Color.bg)
        }
        .listStyle(.plain)
        .cornerRadius(10)
        .padding(8)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.bg)
      .background(selectedLine?.color)
      .cornerRadius(16)
    }
    .padding(.horizontal)
  }

  // MARK: - 방향 선택 페이지
  private var directionSelectionPage: some View {
    VStack(spacing: 10) {
      HStack {
        Text("어느 방향으로 가시나요?")
          .askCapsule()
        Spacer()
      }

      VStack(spacing: .zero) {
        HStack(spacing: .zero) {
          // 상행선 1번
          if let upper1 = selectedStation?.upperStationID_1 {
            Button {
              withAnimation(customAnimation) {
                directionStationID = upper1
                selectionStep = .pre
                confetti += 1
              }
            } label: {
              Text(StationInfo.fetchStationName(from: upper1))
                .bold()
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
          } else {
            Color.black.opacity(0.5)
          }

          Rectangle()
            .trim(from: 0, to: 0.5)
            .stroke(style: .init(lineWidth: 2, dash: [5]))
            .frame(width: 2)

          // 하행선 1번
          if let lower1 = selectedStation?.lowerStationID_1 {
            Button {
              withAnimation(customAnimation) {
                directionStationID = lower1
                selectionStep = .pre
                confetti += 1
              }
            } label: {
              Text(StationInfo.fetchStationName(from: lower1))
                .bold()
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
          } else {
            Color.black.opacity(0.5)
          }
        }

        Rectangle()
          .trim(from: 0, to: 0.5)
          .stroke(style: .init(lineWidth: 2, dash: [5]))
          .frame(height: 2)
          .opacity(selectedStation?.upperStationID_2 == nil && selectedStation?.lowerStationID_2 == nil ? 0 : 1)

        // 상행선 2번 또는 하행선 2번 (둘 다 존재하는 케이스는 없음)
        Group {
          if let upper2 = selectedStation?.upperStationID_2 {
            Button {
              withAnimation(customAnimation) {
                directionStationID = upper2
                selectionStep = .pre
                confetti += 1
              }
            } label: {
              Text(StationInfo.fetchStationName(from: upper2))
                .bold()
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
          } else if let lower2 = selectedStation?.lowerStationID_2 {
            Button {
              withAnimation(customAnimation) {
                directionStationID = lower2
                selectionStep = .pre
                confetti += 1
              }
            } label: {
              Text(StationInfo.fetchStationName(from: lower2))
                .bold()
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
          }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.1)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .font(.largeTitle)
      .foregroundColor(.white)
      .background(Color.bg)
      .background(selectedLine?.color)
      .cornerRadius(16)
      .overlay(alignment: .top) {
        Text(selectedStation?.stationName ?? "")
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

fileprivate enum SelectionStep: CaseIterable {
  case pre
  case lineNumber
  case station
  case direction

  static var maxIndex: Int {
    SelectionStep.allCases.count - 1
  }
}

// MARK: SwiftUI previews

struct SelectionView_Previews: PreviewProvider {
  static var previews: some View {
    SelectionView(
      selectedStation: .constant(
        .init(
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
      directionStationID: .constant("1002000227"))
  }
}
