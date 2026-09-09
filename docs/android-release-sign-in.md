# Android APK release sign-in

This app uses package `com.biholive.net`. Its checked-in Firebase Android app is
`1:976789308527:android:4e19aefee883728a46399a` in project `biholive-a0045`.
`android/app/google-services.json` contains no OAuth clients. Google login uses
the separately supplied OAuth project number `107414380235`:

- Web client (ID-token audience):
  `107414380235-s5cmfapqeosv3r63d6g51e377vp4sdkq.apps.googleusercontent.com`
- Android client (package/signing-certificate registration):
  `107414380235-hib15u613h69bi1k3djqpjj97bm6o869.apps.googleusercontent.com`

Google authentication initializes when login is requested. `GoogleAuthService`
passes the web client above as `serverClientId` by default, so ordinary release
builds include it. A different backend client can be supplied with
`--dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com`.
The value must be a **Web application** OAuth client, not an Android client.
The Android client ID is configured in Google Cloud; it is not passed as the
Dart `clientId` or `serverClientId` on Android.
The backend must validate ID tokens against this same audience. The backend's
existing field `server_auth_code` still carries the Google **ID token**.

## Complete the release configuration

1. Use the actual APK's signing certificate. For a directly installed APK, this
   is the key that signed that file; a debug or Play signing certificate does
   not substitute for it. Inspect the APK with Android SDK Build Tools:

   ```sh
   "$ANDROID_SDK_ROOT/build-tools/36.0.0/apksigner" verify --print-certs /path/to/app-release.apk
   ```

2. In Google Cloud project number `107414380235`, open the Android OAuth client
   above and verify that its package is `com.biholive.net` and its SHA-1 equals
   the actual APK signing certificate. If another signing identity also needs
   to work, add a separate Android client for that package/certificate pair.
   Play-distributed builds use the Play app signing certificate, which can
   differ from the upload or directly installed APK certificate.
3. Confirm the backend validates Google ID tokens against the web client above.
   This app sends Google ID tokens directly to its backend; it does not use
   Firebase Authentication for this flow. The separate Firebase configuration
   can remain for messaging. If moving authentication into the Firebase project
   instead, register the signing certificate there, enable Google sign-in, and
   download its updated `google-services.json`; update the app's web client and
   backend audience together.
4. Restore the existing release key via the ignored `android/key.properties`.
   Keep the original signing identity; do not generate a replacement just to
   make the build pass. This workspace had no `android/key.properties` or built
   APK when inspected, so the release SHA-1 could not be checked locally.
5. Build with the intended release configuration and install the resulting APK:

   ```sh
   flutter build apk --release
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```

   No `GOOGLE_SERVER_CLIENT_ID` build flag is needed for the supplied web client.

6. Verify account selection, cancellation, login success, and retry after a
   backend/network error. The app must remain on login until the backend returns
   a valid session. Test the release APK, since widget tests cannot verify
   Google OAuth registrations or Android signing certificates.

If account selection opens and then closes without signing in, inspect the APK's
package/SHA-1 registration first. Android Credential Manager can report a
configuration mismatch as cancellation, so the picker opening does not prove
that the OAuth configuration is valid. Filter device logs for `GOOGLE-AUTH` to
distinguish a Google error from a backend rejection; do not share ID tokens or
session tokens.

## Live-room release verification

Open a room, receive a reaction, and repeatedly open/dismiss gifts, viewers,
profile, and the close dialog. Focus the comment field, expand media controls,
and test mic/camera actions while connected. Confirm close returns to the room
list once, including when a modal is open, then re-enter the room.

The fix restores the missing room timer/reaction-controller initialization,
normalizes optional host VIP data, reads display size during layout, and keeps
widget controllers alive until the route finishes leaving. Async close events
are guarded against duplicate navigation. Widget tests cover modal controls and
login routing with platform/backend fakes; native LiveKit and Google login still
require the signed APK check above.

Reference: [Flutter Google Sign-In Android configuration and troubleshooting](https://pub.dev/packages/google_sign_in_android#troubleshooting).
