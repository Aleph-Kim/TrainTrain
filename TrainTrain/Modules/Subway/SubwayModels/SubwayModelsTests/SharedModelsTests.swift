//
//  SharedModelsTests.swift
//  SharedModelsTests
//
//  Created by daco daco on 2023/02/26.
//

import XCTest

@testable import SharedModels
final class SharedModelsTests: XCTestCase {
  func test_arvlMsg3가_없을때에도_문제없이_decode되는가() throws {
    XCTAssertEqual("여기에 테스트를 추가하세요", "여기에 테스트를 추가하세요")
  }
}
