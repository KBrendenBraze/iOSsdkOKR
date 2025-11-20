# Braze iOS SDK Demo

This repository now includes a ready-to-run SwiftUI sample application that exercises the Braze iOS SDK end-to-end:

- Initializes BrazeKit, BrazeUI, and BrazeKitCompat on launch
- Implements `changeUser()` and captures common data inputs (custom events, purchases, custom attributes)
- Demonstrates push plumbing (APNs registration + Braze notification delegation)
- Retrieves Braze Content Cards and renders them with live updates
- Requests in-app message display and forces data flushes so you can trigger a communication channel from the Braze dashboard

## Repository layout

- `BrazeDemoApp/` – Xcode project, Swift sources, assets, and configuration plists
  - `BrazeDemoApp.swift`, `AppDelegate.swift`, `BrazeManager.swift`, `ContentView.swift`
  - `BrazeDemoApp.xcodeproj` already references the [Braze Swift SDK](https://github.com/braze-inc/braze-swift-sdk) via Swift Package Manager (pinned to 13.3.0)
  - `BrazeConfiguration.example.plist` – sample config that you should copy to `BrazeConfiguration.plist` (ignored by git) with your API key, endpoint, and a default user id

## Getting started

1. `cp BrazeDemoApp/BrazeConfiguration.example.plist BrazeDemoApp/BrazeConfiguration.plist` and edit the values for `apiKey`, `endpoint`, and `defaultUserId`.
2. Open `BrazeDemoApp/BrazeDemoApp.xcodeproj` in Xcode 15+.
3. Select the `BrazeDemoApp` target, set your Apple `DEVELOPMENT_TEAM`, and let Xcode resolve the Braze Swift Package (13.3.0).
4. Build & run on a simulator or device. The first launch requests push permissions from the SDK section of the UI when you tap the button.

## Verifying Braze communication flows

Inside the running app you can:

- **Change users** – type a Braze user id and tap “Apply user”; the UI updates and `Braze.changeUser` is invoked.
- **Send data** – log a custom event or purchase, or set a custom attribute; each call updates the status label.
- **Retrieve Content Cards** – tap “Refresh content cards” to call `Braze.contentCards.requestRefresh`. The list view live-updates via `subscribeToUpdates`.
- **Trigger an in-app message** – tap “Trigger in-app message sync” after scheduling an IAM in the Braze dashboard for the active user. The sample sets `BrazeInAppMessageUI.Presenter` so the message renders in-app.
- **Exercise push** – tap “Request push permissions” to register the device token with Braze. Foreground/background notification delegates already forward Braze payloads.
- **Force a flush** – tap “Flush data to Braze” to call `requestImmediateDataFlush()` when you need to force send/receive.

Use Braze’s dashboard to send at least one channel (Content Cards, IAM, or Push) to the selected user id, then use the in-app buttons to observe it arriving.

## Next steps

- Drop in real app icons under `Assets.xcassets/AppIcon`.
- Wire a Notification Service Extension (`BrazeNotificationService`) or Push Story if needed.
- Add any advanced Braze features (Content Cards UI customization, in-app message delegates, analytics hooks, etc.).
