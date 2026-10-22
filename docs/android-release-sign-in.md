# Ringo Live signing and Firebase configuration

Updated 22 October 2026 from the local Max Live project at
`/Users/smtanvirhasanfaysal/project/max_Live`.

## App identity

The visible Android, iOS, and Flutter app name is **Ringo Live**. Launcher icons,
the in-app logo, and the diamond icon use Max Live's existing artwork.

Both native platforms use `com.maxliveonline.org.bd`, matching the imported
Firebase registrations. Android's namespace and `MainActivity` package, iOS
Runner and test bundle identifiers, the Play Store URL, and the local
`web_deeplink` files have been aligned. This is a different application identity
from the previous `com.biholive.net` build. It installs separately and cannot be
submitted as an update to the old package's store listing.

The backend remains `https://biholive.com`; existing streaming URL paths and
the `biholive` custom URL scheme remain in use. Serve the updated
`web_deeplink/.well-known/assetlinks.json` and streaming fallback page on that
domain for verified links to recognize the new package and certificate. These
files have only been updated locally. For Play-distributed builds, the asset
links file must also include the actual Play App Signing certificate if it
differs from the imported local key.

## Android signing

The active Max Live release key is copied to `android/upload-keystore.jks`.
`android/key.properties` references `../upload-keystore.jks`, relative to
`android/app`. Both files remain ignored by Git and have owner-only permissions.
Passwords remain in the local properties file. Debug, profile, and release
builds use this key when the properties file is present.

Public certificate fingerprints:

```text
SHA-1:   1A:A0:29:76:6D:43:FF:A0:EB:6B:A3:9F:74:A3:25:60:03:86:9F:D9
SHA-256: 41:88:58:0C:D0:17:FE:48:88:61:E6:35:EA:26:11:9B:3C:1B:A2:A1:73:1D:5F:FE:87:B3:44:8B:61:D8:8A:FA
```

## Firebase

The following files were imported from Max Live:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`
- `firebase.json`

They select project `max-live-af375`, project number `728790055596`:

| Platform | Firebase app ID |
| --- | --- |
| Android | `1:728790055596:android:198565fba5b23037943d09` |
| iOS | `1:728790055596:ios:b51d31929bde9f53943d09` |
| Web | `1:728790055596:web:3524b168a657c219943d09` |

App startup initializes Firebase with the imported platform options. Native
configuration files are also included in the existing Android and iOS build
integration. No Firebase administrative credentials are copied into the app.

## Google sign-in

Max Live's active Google OAuth configuration is separate from its Firebase
project. The imported source app explicitly uses these OAuth clients:

| Purpose | Client ID |
| --- | --- |
| Web/server token audience | `1028099754767-b9nvqcl8egtdevcoegjmkcmffj6he59i.apps.googleusercontent.com` |
| iOS | `1028099754767-0r0lctguquljs8lkah5qa6ef1kths8cl.apps.googleusercontent.com` |

`GoogleAuthService` uses this server audience on Android and iOS. iOS also has
the matching `GIDClientID`, `GIDServerClientID`, and reversed-client callback
scheme in `Info.plist`. `GOOGLE_SERVER_CLIENT_ID` remains available as an
explicit build-time override. Android resolves its Android OAuth registration
from the installed package and signing certificate; an Android OAuth client
ID is never passed as the server client ID.

The imported Firebase Android JSON contains a different web client,
`728790055596-me9hoir06brttbf41lva9onuokr4fvts.apps.googleusercontent.com`, and
no Android OAuth certificate entries. Its iOS OAuth entry refers to a different
bundle ID. Those snapshot entries are not used to replace Max Live's active
sign-in settings, and do not prove which registrations are currently live.

The app sends a Google **ID token** directly to
`https://biholive.com/api/v1/auth/login/` under the legacy `server_auth_code`
field. The backend must accept the imported web client as a token audience.
It must verify the Google token's signature, issuer, audience, and expiry.
Firebase Authentication is not part of this app's login flow.

## Runtime verification

Local configuration and fake-platform tests cannot establish live OAuth
registration, backend audience acceptance, or push delivery. On a device,
verify Google sign-in with a build signed by the imported key, then verify
foreground and background FCM delivery. The backend's FCM sender must use
credentials for `max-live-af375`; credentials for the previous Firebase
project cannot send to this project's device tokens. Backend credentials,
Firebase Console registrations, store listings, and hosted app-link files
were not changed by this local migration.
