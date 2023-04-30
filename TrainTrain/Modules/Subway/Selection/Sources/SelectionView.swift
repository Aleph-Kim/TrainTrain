//
//  NewSelectionView.swift
//  Arrival
//
//  Created by Geonhee on 2023/04/02.
//

import ComposableArchitecture
import SubwayModels
import SwiftUI
import TTDesignSystem
import TTFoundation
import ConfettiSwiftUI

public struct SelectionView: View {

  public let store: StoreOf<SelectionFeature>
  @FocusState private var focus: SelectionFeature.State.Field?
  private let tabTransitionAnimation: Animation = .easeInOut(duration: 0.25)

  public init(store: StoreOf<SelectionFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      TabView(selection: viewStore.binding(\.$selectionStep)) {
        preSelectionPage(viewStore: viewStore)
          .tag(SelectionFeature.State.SelectionStep.pre)
          .highPriorityGesture(DragGesture())

        lineNumberSelectionPage(viewStore: viewStore)
          .tag(SelectionFeature.State.SelectionStep.lineNumber)
          .highPriorityGesture(DragGesture())

        stationSelectionPage(viewStore: viewStore)
          .tag(SelectionFeature.State.SelectionStep.station)
          .highPriorityGesture(DragGesture())

        directionSelectionPage(viewStore: viewStore)
          .tag(SelectionFeature.State.SelectionStep.direction)
          .highPriorityGesture(DragGesture())
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .confettiCannon(
        counter: viewStore.binding(\.$confetti),
        rainHeight: 400,
        openingAngle: .degrees(45),
        closingAngle: .degrees(135),
        repetitions: 1
      )
    }
  }

  // MARK: - 선택해주세요 / 완료 페이지
  private func preSelectionPage(viewStore: ViewStoreOf<SelectionFeature>) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Spacer()
      let infoMessage = "영차열차로\n확인하고 싶은 👀\n역을 선택해주세요."

      Text(infoMessage)
        .font(.title)
        .lineSpacing(6)
        .minimumScaleFactor(0.6)
        .onAppear {
          viewStore.send(.commitSelection)
        }

      Spacer()

      let lineColor = viewStore.selectedSubwayLine.color

      VStack(alignment: .leading, spacing: 4) {
        Text(viewStore.selectedSubwayLine.name)
          .colorCapsule(lineColor)

        HStack {
          Text(viewStore.selectedStation.stationName)
            .colorCapsule(lineColor)

          Image(systemName: "arrow.right")

          Text(viewStore.directionStation.stationName)
            .colorCapsule(lineColor)
        }
      }

      Spacer()

      Button {
        viewStore.send(.startSelectionButtonTapped, animation: tabTransitionAnimation)
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
  private func lineNumberSelectionPage(viewStore: ViewStoreOf<SelectionFeature>) -> some View {
    VStack(spacing: 10) {
      header(title: "몇 호선 인가요?") {
        viewStore.send(.selectSubwayLineBackButtonTapped, animation: tabTransitionAnimation)
      }

      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 20) {
          ForEach(SubwayLine.allCases) { subwayLine in
            Button {
              viewStore.send(.subwayLineTapped(subwayLine), animation: tabTransitionAnimation)
            } label: {
              HalfCapsule(line: subwayLine)
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

  private func header(title: String, backButtonAction: @escaping () -> Void) -> some View {
    HStack {
      headerTitle(title)
      Spacer()
      backButton(action: backButtonAction)
    }
  }

  private func headerTitle(_ title: String) -> some View {
    Text(title)
      .askCapsule()
  }

  private func backButton(action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Image(systemName: "arrow.uturn.left")
        .askCapsule(bold: false)
        .tint(.primary)
    }
    .buttonStyle(ReactiveButton())
  }

  // MARK: - 역 선택 페이지
  private func stationSelectionPage(viewStore: ViewStoreOf<SelectionFeature>) -> some View {
    VStack(spacing: 10) {

      HStack {
        if let selectedSubwayLine = viewStore.selectionState.selectedLine {
          let lineColor = selectedSubwayLine.color
          Text(selectedSubwayLine.name)
            .colorCapsule(lineColor)
        }
        header(title: "어느 역에서 탑승하세요?") {
          viewStore.send(.selectStationBackButtonTapped, animation: tabTransitionAnimation)
        }
      }

      VStack(spacing: .zero) {
        TextField("➡️ 탑승역 검색", text: viewStore.binding(\.$searchText))
          .textFieldStyle(.roundedBorder)
          .cornerRadius(10)
          .padding(.horizontal, 8)
          .padding(.top, 8)
          .submitLabel(.search)
          .focused($focus, equals: .searchStationField)
          .bind(viewStore.binding(\.$focus), to: $focus)

        let cleanedSearchText = viewStore.searchText.cleaned
        let filteredStationList = cleanedSearchText.isEmpty
          ? viewStore.stationList
          : viewStore.stationList.filter { $0.stationName.contains(cleanedSearchText) }

        List(filteredStationList, id: \.stationID) { station in
          Button {
            viewStore.send(.stationTapped(station), animation: tabTransitionAnimation)
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
      .background(viewStore.selectionState.selectedLine?.color)
      .cornerRadius(16)
    }
    .padding(.horizontal)
  }

  // MARK: - 방향 선택 페이지
  private func directionSelectionPage(viewStore: ViewStoreOf<SelectionFeature>) -> some View {
    VStack(spacing: 10) {
      header(title: "어느 방향으로 가세요?") {
        viewStore.send(.selectDirectionStationBackButtonTapped, animation: tabTransitionAnimation)
      }

      VStack(spacing: 3) {
        HStack(spacing: 3) {
          if let upper1DirectionStation = viewStore.upper1DirectionStation {
            selectDirectionStationButton(viewStore: viewStore, directionStation: upper1DirectionStation)
          } else {
            emptyDirectionStationView(selectedSubwayLineColor: viewStore.selectionState.selectedLine?.color)
          }

          if let lower1DirectionStation = viewStore.lower1DirectionStation {
            selectDirectionStationButton(viewStore: viewStore, directionStation: lower1DirectionStation)
          } else {
            emptyDirectionStationView(selectedSubwayLineColor: viewStore.selectionState.selectedLine?.color)
          }
        }

        Group {
          // 상행선 2번 또는 하행선 2번 (둘 다 존재하는 케이스는 없음)
          if let upper2DirectionStation = viewStore.upper2DirectionStation {
            selectDirectionStationButton(viewStore: viewStore, directionStation: upper2DirectionStation)
          }

          if let lower2DirectionStation = viewStore.lower2DirectionStation {
            selectDirectionStationButton(viewStore: viewStore, directionStation: lower2DirectionStation)
          }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.15)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .font(.largeTitle)
      .foregroundColor(.white)
      .cornerRadius(16)
      .overlay(alignment: .top) {
        let selectedStationName = viewStore.selectionState.selectedStation?.stationName ?? viewStore.selectedStation.stationName

        Text(selectedStationName)
          .fontWeight(.bold)
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

  private func selectDirectionStationButton(
    viewStore: ViewStoreOf<SelectionFeature>,
    directionStation: StationInfo
  ) -> some View {
    Button {
      viewStore.send(.directionStationTapped(directionStation), animation: tabTransitionAnimation)
    } label: {
      Text(directionStation.stationName)
        .bold()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 10)
        .background(viewStore.selectionState.selectedLine?.color)
        .cornerRadius(16)
    }
    .buttonStyle(ReactiveButton())
  }

  private func emptyDirectionStationView(selectedSubwayLineColor: Color?) -> some View {
    selectedSubwayLineColor
      .opacity(0.5)
      .cornerRadius(16)
  }
}
