//
//  UserDefaultsManager.swift
//  TTUserDefaults
//
//  Created by Geonhee on 2023/02/08.
//

import Dependencies
import Foundation

public final class UserDefaultsClient {

  private let userDefaults: UserDefaults

  public init(
    userDefaults: UserDefaults = .standard
  ) {
    self.userDefaults = userDefaults
  }

  /// 선택한 호선
  @UserDefault(.subwayLine, defaultValue: "1002") // 2호선
  public var subwayLine: String

  /// 선택된 출발역 ID
  @UserDefault(.selectedStationID, defaultValue: "1002000222") // 강남
  public var selectedStationID: String

  /// 선택한 진행방향 역 ID
  @UserDefault(.directionStationID, defaultValue: "1002000221") // 역삼
  public var directionStationID: String

  /// 호선, 출발, 진행방향을 처음 선택하는지 여부
  @UserDefault(.firstSetting, defaultValue: true)
  public var firstSetting: Bool
}

// MARK: - UserDefaults Keys

enum UserDefaultsKey: String {
  /// 선택한 호선
  case subwayLine
  /// 선택된 출발역 ID
  case selectedStationID
  /// 선택한 진행방향 역 ID
  case directionStationID
  /// 호선, 출발, 진행방향을 처음 선택하는지 여부
  case firstSetting
}

// MARK: - Register Dependency

private enum UserDefaultsClientKey: DependencyKey {
  static let liveValue = UserDefaultsClient(userDefaults: .standard)
}

public extension DependencyValues {
  var userDefaultsClient: UserDefaultsClient {
    get { self[UserDefaultsClientKey.self] }
    set { self[UserDefaultsClientKey.self] = newValue }
  }
}
