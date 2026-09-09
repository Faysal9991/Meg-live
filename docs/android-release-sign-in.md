# Android APK release sign-in

This app uses package `com.biholive.net`. Its checked-in Firebase Android app is
`1:976789308527:android:4e19aefee883728a46399a` in project `biholive-a0045`.
At the time of this fix, `android/app/google-services.json` contained no OAuth
clients. The previously hardcoded web client belonged to project number
`107414380235`, so it could not be verified against this Firebase configuration.

Google authentication now initializes when login is requested. By default,
Android reads the web client from `google-services.json`; an explicitly managed
backend client can instead be supplied with
`--dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com`.
The value must be a **Web application** OAuth client, not an Android client.
The backend must validate ID tokens against this same audience. The backend's
existing field `server_auth_code` still carries the Google **ID token**.

## Complete the release configuration

1. Use the actual APK's signing certificate. For a directly installed APK, this
   is the key that signed that file; a debug or Play signing certificate does
   not substitute for it. Inspect the APK with Android SDK Build Tools:

   ```sh
   "$ANDROID_SDK_ROOT/build-tools/36.0.0/apksigner" verify --print-certs /path/to/app-release.apk
   ```

2. In the Firebase/Google Cloud project used for authentication, register the
   Android package `com.biholive.net` with that certificate's SHA-1. Add its
   SHA-256 in Firebase project settings as well. Confirm the Android OAuth
   client and the Web application OAuth client are configured in the intended
   project. If using Firebase Authentication, enable the Google provider.
3. Download the updated `google-services.json` to `android/app/`. It should
   include an Android OAuth registration (`client_type: 1`) and a Web client
   (`client_type: 3`). If intentionally using a separately managed OAuth
   project, use its matching Android registration and explicit web client define.
4. Restore the existing release key via the ignored `android/key.properties`.
   Keep the original signing identity; do not generate a replacement just to
   make the build pass. This workspace had no `android/key.properties` when
   inspected, and the signed-in Firebase CLI account received HTTP 403 for this app.
5. Build with the intended release configuration and install the resulting APK:

   ```sh
   flutter build apk --release
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```

6. Verify account selection, cancellation, login success, and retry after a
   backend/network error. The app must remain on login until the backend returns
   a valid session. Test the release APK, since widget tests cannot verify
   Google OAuth registrations or Android signing certificates.

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
