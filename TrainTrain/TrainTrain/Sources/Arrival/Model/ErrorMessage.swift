import Foundation

struct ErrorMessage: Decodable {
  
  let status: Int
  let code: String
  let message: String
  let link: String
  let developerMessage: String
  let total: Int
}
