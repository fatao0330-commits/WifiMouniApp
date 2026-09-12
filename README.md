# wifi_mouni

A new Flutter project created with FlutLab - https://flutlab.io

## Firebase setup

The app requires a Firebase project before running the authentication and wallet features:

- Add `google-services.json` to `android/app/`.
- Add `GoogleService-Info.plist` to `ios/Runner/` through Xcode.
- Enable Firebase Authentication with the Email/Password provider.
- Create the Firestore collections `subscriptions`, `payment_methods`, `settings/recharge`, `wallets`, and `recharge_requests`.
- Configure Firebase Storage rules for authenticated users uploading under `recharge_proofs/{userUid}`.

The client only creates `recharge_requests` with status `pending`. Wallet balances must be changed by a trusted backend or Cloud Function after payment verification.

## Getting Started

A few resources to get you started if this is your first Flutter project:

- https://flutter.dev/docs/get-started/codelab
- https://flutter.dev/docs/cookbook

For help getting started with Flutter, view our
https://flutter.dev/docs, which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Getting Started: FlutLab - Flutter Online IDE

- How to use FlutLab? Please, view our https://flutlab.io/docs
- Join the discussion and conversation on https://flutlab.io/residents
