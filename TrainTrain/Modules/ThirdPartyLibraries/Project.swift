//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Geonhee on 2023/03/30.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
  name: "ThirdPartyLibraries",
  targetConfigurations: [
    TargetConfiguration(
      name: "CoreLibraries",
      targetTypes: [],
        productType: .framework,
        dependencies: [
          .external(name: "ComposableArchitecture"),
        ]
    ),
  ],
  packages: [],
  additionalFiles: []
)
