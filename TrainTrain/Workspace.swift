import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

// MARK: - Workspace
// Local plugin loaded
let localHelper = LocalHelper(name: "MyPlugin")

let workspace = Workspace(
  name: "TrainTrain",
  projects: [
    "Modules/Platform",
    "Modules/Subway",
    "Modules/TrainTrainApp",
    "Modules/TTDesignSystem",
  ],
  additionalFiles: []
)
