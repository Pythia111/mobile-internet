# Mobile Internet HarmonyOS Client

Native HarmonyOS application for the Mobile Internet project.

## Technologies

- HarmonyOS SDK 10
- ArkTS (TypeScript for HarmonyOS)
- ArkUI (Declarative UI framework)

## Project Structure

```
harmony-client/
├── entry/
│   └── src/
│       └── main/
│           ├── ets/
│           │   ├── entryability/
│           │   │   └── EntryAbility.ets    # Application entry point
│           │   └── pages/
│           │       └── Index.ets           # Main page
│           ├── resources/                  # App resources
│           └── module.json5                # Module configuration
├── app.json5                               # App configuration
└── build-profile.json5                     # Build configuration
```

## Prerequisites

To build and run this HarmonyOS application, you need:

- DevEco Studio (HarmonyOS IDE)
- HarmonyOS SDK 10 or higher
- HarmonyOS device or emulator

## Getting Started

### 1. Install DevEco Studio

Download and install DevEco Studio from the official Huawei developer website:
https://developer.harmonyos.com/cn/develop/deveco-studio

### 2. Configure SDK

1. Open DevEco Studio
2. Go to File > Settings > SDK
3. Install HarmonyOS SDK API 10 or higher

### 3. Open Project

1. Open DevEco Studio
2. Select "Open Project"
3. Navigate to the `harmony-client` directory
4. Click "OK"

### 4. Build and Run

1. Connect a HarmonyOS device or start an emulator
2. Click the "Run" button in DevEco Studio
3. Select your target device
4. The app will be built and deployed to the device

## Features

- Native HarmonyOS UI built with ArkTS
- Connection to Spring Boot backend
- Modern declarative UI with ArkUI
- Support for phones and tablets

## Backend Connection

The app is configured to connect to the Spring Boot backend running at:
- Local development: `http://localhost:8080`

To enable backend connection:
1. Start the Spring Boot backend server
2. Update the backend URL in the app if needed
3. Click "Connect to Backend" button in the app

## Development

### File Structure

- `EntryAbility.ets`: Application lifecycle management
- `Index.ets`: Main page UI and logic
- `module.json5`: Module configuration and abilities
- `app.json5`: Application metadata

### Adding New Pages

1. Create a new `.ets` file in `entry/src/main/ets/pages/`
2. Add the page to `main_pages.json`
3. Navigate to the page using router

### Building for Release

1. Configure signing certificate in DevEco Studio
2. Select "Build > Build Hap(s)/App(s) > Build Hap(s)"
3. The output will be in `build/outputs/`

## Notes

- This is a basic HarmonyOS application structure
- Requires DevEco Studio for full development and deployment
- HarmonyOS SDK must be installed to build the project
