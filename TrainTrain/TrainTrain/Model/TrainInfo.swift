import Foundation

struct TrainInfo: Decodable {

  /// - Note: 통신 결과에 대한 각종 상태값과 조회 가능한 전체 열차의 개수가 담겨있습니다.
  let errorMessage: ErrorMessage
  /// - Note: 특정 지하철역에 대한 실시간 도착정보가 배열 형태로 담겨있습니다.
  let realtimeArrivalList: [RealtimeArrivalList]
}
