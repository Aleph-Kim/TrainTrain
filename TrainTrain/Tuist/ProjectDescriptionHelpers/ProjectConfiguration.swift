//
//  ProjectConfiguration.swift
//  ProjectDescriptionHelpers
//
//  Created by Geonhee on 2023/03/28.
//

import ProjectDescription

enum ProjectConfiguration: String {
  case dev = "Debug"
  case stage = "STAGE"
  case prod = "PROD"
}

extension ConfigurationName {
  static let dev = configuration(ProjectConfiguration.dev.rawValue)
  static let stage = configuration(ProjectConfiguration.stage.rawValue)
  static let prod = configuration(ProjectConfiguration.prod.rawValue)
}
