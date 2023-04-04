//
//  PathDescription.swift
//  ProjectDescriptionHelpers
//
//  Created by Geonhee on 2023/03/28.
//

import ProjectDescription

extension Path {
  static let appDevXCConfig: Path = .relativeToRoot("Configurations/App/DEV.xcconfig")
  static let widgetExtensionDevXCConfig: Path = .relativeToRoot("Configurations/WidgetExtension/DEV.xcconfig")
}
