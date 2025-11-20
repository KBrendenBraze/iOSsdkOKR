# Braze iOS Integration Skeleton

This repo intentionally **does not** include the Braze SDK. Instead, it ships a lightweight SwiftUI playground that lets you collect user/profile/event inputs with simple boxes + “Submit” buttons so you can wire each action to Braze yourself while following the public docs.

## What’s inside

- `BrazeDemoApp/`
  - `BrazeDemoApp.xcodeproj` – single SwiftUI target, no external packages
  - `BrazeDemoApp.swift` – app entry point
  - `ContentView.swift` – the UI skeleton containing the user info / custom attribute / custom event forms plus placeholder channel buttons
  - `IntegrationPlaygroundViewModel.swift` – a tiny observable object that just logs the action you tapped (so you know where to drop Braze calls)
  - `BrazeConfiguration.example.plist` – optional template you can duplicate if you want to load keys at runtime once you integrate
  - Minimal asset catalog + Info.plist boilerplate

## Running the app

1. Open `BrazeDemoApp/BrazeDemoApp.xcodeproj` in Xcode 15+.
2. Select the `BrazeDemoApp` target and supply your own `DEVELOPMENT_TEAM` if you plan to deploy to a device.
3. Build & run on a simulator or hardware. You’ll see the “Braze Integration Sandbox” screen with separate boxes for:
   - User identity / profile fields
   - Custom attributes
   - Custom events (with optional key/value)
   - Quick actions for push registration, content cards, IAM, and flush requests
4. Each tap appends a note to the Activity Log describing the Braze API you should hook up (e.g. “wire this to `changeUser()`”).

## How to integrate Braze yourself

- Add the Braze Swift Package (or Cocoapods) to the Xcode project.
- Replace the log-only implementations in `IntegrationPlaygroundViewModel` with real calls:
  - `changeUser()` ⇒ `Braze.shared.changeUser`
  - `setCustomAttribute` ⇒ `braze.user.setCustomAttribute`
  - `logCustomEvent` ⇒ `braze.logCustomEvent`
  - `registerForPush`, `requestContentCards`, `requestInAppMessage`, `flushData` ⇒ hook to the relevant Braze SDK entry points.
- Use the provided text fields and submit buttons as your out-of-the-box UI for testing each flow while you follow Braze’s documentation.

This keeps the app as a clean slate (no Braze SDK code yet) while giving you all the scaffolding needed to plug Braze in on your own timeline.