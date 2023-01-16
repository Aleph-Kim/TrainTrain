APP_TARGET_NAME="TrainTrain"
RESOURCE_PATH=$(echo "$(pwd)/$APP_TARGET_NAME/Resources")
ASSET_TEMPLATE_PATH=$(echo "$RESOURCE_PATH/Templates")
GENERATED_SOURCES_PATH=$(echo "$RESOURCE_PATH/Generated")

swiftgen run xcassets \
  "$RESOURCE_PATH/Colors.xcassets" \
  "$RESOURCE_PATH/Images.xcassets" \
  -p "$ASSET_TEMPLATE_PATH/Assets.stencil" \
  -o "$GENERATED_SOURCES_PATH/Assets+Generated.swift"
