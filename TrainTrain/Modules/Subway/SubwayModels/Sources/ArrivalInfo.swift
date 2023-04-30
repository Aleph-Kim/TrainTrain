import Foundation

public struct ArrivalInfo {

  /// 통신 결과에 대한 각종 상태값과 조회 가능한 전체 열차의 개수가 담겨있습니다.
  public let errorMessage: ErrorMessage
  /// 특정 지하철역에 대한 실시간 도착정보가 배열 형태로 담겨있습니다.
  public let realtimeArrivalList: [TrainInfo]

  public struct ErrorMessage: Decodable {

    public let status: Int
    public let code: String
    public let message: String
    public let link: String
    public let developerMessage: String
    public let total: Int
  }

  public struct Response: Decodable {
    /// 통신 결과에 대한 각종 상태값과 조회 가능한 전체 열차의 개수가 담겨있습니다.
    public let errorMessage: ErrorMessage
    /// 특정 지하철역에 대한 실시간 도착정보가 배열 형태로 담겨있습니다.
    public let realtimeArrivalList: [TrainInfo.Response]
  }
}

public extension ArrivalInfo.Response {
  func toDomain() -> ArrivalInfo {
    return ArrivalInfo(
      errorMessage: errorMessage,
      realtimeArrivalList: realtimeArrivalList.map { $0.toDomain() }
    )
  }
}
