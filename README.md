# Thoughtdrift

A calming iOS journaling app built around a 30-day Cognitive Behavioral Therapy program for anxiety.

- 30 daily prompts and quotes across four weeks (Awareness, Challenge, Reframe, Integrate), one new prompt per day
- Days 1–5 free; days 6–30 unlock with a one-time in-app purchase (`com.aquabunnygames.thoughtdrift.fullprogram`, Non-Consumable)
- Daily home screen after each entry: quote, mood faces slider, and 3 things you’re grateful for
- Weekly check-ins, milestone messages, and a cognitive distortion cheat sheet
- Daily reminders; entries stay on-device
- SwiftUI, iOS 16+, light and dark mode

## Build

Open `Thoughtdrift.xcodeproj` in Xcode and run. To regenerate the project after adding files: `gem install xcodeproj && ruby generate_project.rb`.

Thoughtdrift is a self-help tool, not a substitute for professional care.

## iPhone Duo

Layouts are flexible for iPhone Duo's folding display: no fixed sizes or orientation, adaptive grids, readable-width content, and standard `TabView`/`NavigationStack` navigation so bars adapt automatically. Build with the **iOS 27.1 SDK or later** in Xcode to get the full-display behavior (apps built with older SDKs are letterboxed), and test fold/unfold poses and Split View in the simulator.

## In-app purchase

- Product: **Full Program**, type **Non-Consumable**, Product ID `com.aquabunnygames.thoughtdrift.fullprogram` (see `PurchaseConfig` in `Purchases.swift`).
- Local testing: Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration → `Thoughtdrift.storekit`.
- TestFlight uses the sandbox and the product created in App Store Connect.
