//
//  TargetConfiguration.swift
//  ProjectDescriptionHelpers
//
//  Created by Geonhee on 2023/03/18.
//

import ProjectDescription


public struct TargetConfiguration {

  public enum TargetType {
    case unitTest
    case preview
  }

  public let name: String
  public let targetTypes: [TargetType]
  public let productType: Product
  public let resources: [String]
  public let dependencies: [TargetDependency]
  public let unitTestDependencies: [TargetDependency]
  public let uiTestTestDependencies: [TargetDependency]

  public init(
    name: String,
    targetTypes: [TargetType] = [],
    productType: Product,
    resources: [String] = [],
    dependencies: [TargetDependency] = [],
    unitTestDependencies: [TargetDependency] = [],
    uiTestTestDependencies: [TargetDependency] = []
  ) {
    self.name = name
    self.targetTypes = targetTypes
    self.productType = productType
    self.resources = resources
    self.dependencies = dependencies
    self.unitTestDependencies = unitTestDependencies
    self.uiTestTestDependencies = uiTestTestDependencies
  }
}

