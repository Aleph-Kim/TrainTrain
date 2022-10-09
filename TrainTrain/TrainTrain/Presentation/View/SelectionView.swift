import SwiftUI
import ConfettiSwiftUI

struct SelectionView: View {

  @State private var selectionStep: SelectionStep = .pre
  @State private var selectedLine: SubwayLine? // 나중에 View 합쳐질 때 @Binding 으로 외부와 연결시킬 듯
  @State private var selectedStation: StationInfo?
  @State private var selectedDirection: String? // "OO방면"
  @State private var stationList: [StationInfo] = []
  @State private var searchText = ""
  @State private var confetti: Int = .zero

  // MARK: - body
  var body: some View {
    VStack {
      TabView(selection: $selectionStep) {
        preSelectionPage.tag(SelectionStep.pre)
  //        .gesture(DragGesture())
        lineNumberSelectionPage.tag(SelectionStep.lineNumber)
  //        .gesture(DragGesture())
        stationSelectionPage.tag(SelectionStep.station)
  //        .gesture(DragGesture())
        directionSelectionPage.tag(SelectionStep.direction)
  //        .gesture(DragGesture())
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.4) // 화면 높이의 40% 사용

      // MARK: - 커스텀 페이지 인디케이터
      HStack(spacing: 10) {
        ForEach(SelectionStep.allCases.indices, id: \.self) { index in
          Circle()
            .fill(isCurrentPage(for: index) ? .secondary : Color.bg)
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

      if let selectedLine, let selectedStation, let selectedDirection {
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

            Text(selectedDirection.replacingOccurrences(of: "방면", with: ""))
              .colorCapsule(selectedLine.color)
          }
        }
      } else {
        Text("영차열차로\n확인하고 싶은\n역을 선택해주세요. 👀")
          .font(.title)
          .lineSpacing(6)
          .minimumScaleFactor(0.6)
      }

      Spacer()

      Button {
        withAnimation {
          selectionStep = .lineNumber
        }
      } label: {
        Text(selectedDirection == nil ? "선택 시작 →" : "다시 선택하기 →")
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
              withAnimation {
                selectedLine = line
                selectionStep = .station
                stationList = fetchStationList(of: line)
              }
            } label: {
              Capsule()
                .fill(line.color)
                .frame(height: 42)
                .overlay(alignment: .leading) {
                  Text(line.rawValue)
                    .foregroundColor(.black)
                    .bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white)
                    .clipShape(Capsule())
                    .padding(.leading, 8)
                }
                .overlay(alignment: .trailing) {
                  line.color
                    .frame(width: 20)
                }
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
          .onChange(of: searchText) { newValue in
            searchText = newValue.cleaned
          }

        List(searchText.isEmpty
             ? stationList
             : stationList.filter { $0.stationName.contains(searchText) }
             , id: \.stationID) { station in
          Button {
            withAnimation {
              selectedStation = station
              selectionStep = .direction
            }
          } label: {
            HStack {
              Text(station.stationName + "역")
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

      HStack(spacing: .zero) {
        Button {
          withAnimation {
            selectedDirection = previousStationName + "방면"
            selectionStep = .pre
            confetti += 1
          }
        } label: {
          Text(previousStationName)
            .bold()
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .disabled(previousStationName.isEmpty)

        Rectangle()
          .trim(from: 0, to: 0.5)
          .stroke(style: .init(lineWidth: 2, dash: [5]))
          .frame(width: 2)

        Button {
          withAnimation {
            selectedDirection = nextStationName + "방면"
            selectionStep = .pre
            confetti += 1
          }
        } label: {
          Text(nextStationName)
            .bold()
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .disabled(nextStationName.isEmpty)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .font(.largeTitle)
      .foregroundColor(.white)
      .background(Color.bg)
      .background(selectedLine?.color)
      .cornerRadius(16)
      .overlay(alignment: .top) {
        Text(selectedStation?.stationName ?? "" + "역")
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

  // MARK: - 이전(왼쪽) 역
  private var previousStationName: String {
    guard let selectedStation else { return "" }
    guard let index = stationList.firstIndex(where: { $0.stationID == selectedStation.stationID }) else { return "" }
    guard index < (stationList.count - 1) else { return "" }
    return stationList[index + 1].stationName
  }

  // MARK: - 다음(오른쪽) 역
  private var nextStationName: String {
    guard let selectedStation else { return "" }
    guard let index = stationList.firstIndex(where: { $0.stationID == selectedStation.stationID }) else { return "" }
    guard index > 0 else { return "" }
    return stationList[index - 1].stationName
  }

  // MARK: - 역정보 가져오기
  private func fetchStationList(of line: SubwayLine) -> [StationInfo] {
    let path = Bundle.main.path(forResource: "StationList220622", ofType: "plist")!
    let arrOfDict = NSArray(contentsOfFile: path)! as! [[String: Any]]
    let stations = arrOfDict.map {
      StationInfo(
        subwayLineID: $0["SUBWAY_ID"]!,
        stationID: $0["STATN_ID"]!,
        stationName: $0["STATN_NM"]!)
    }
    let filtered = stations.filter { $0.subwayLineID == line.id }
    return filtered
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

extension View {
  // 필요 없어지면 삭제할 예정! -- modifier 를 조건문에 따라 적용하기 위한 메서드임
  @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}

struct SelectionView_Previews: PreviewProvider {
  static var previews: some View {
    SelectionView()
  }
}
