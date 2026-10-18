# Android Google sign-in

This app uses package `com.biholive.net`. Its Firebase Android app is
`1:976789308527:android:4e19aefee883728a46399a` in project `biholive-a0045`
(project number `976789308527`). The current `android/app/google-services.json`
contains Android OAuth clients and this Web application client:

```text
976789308527-a7ie4kfg7le4ae4aoasdpgfafg9pqcga.apps.googleusercontent.com
```

On Android, `GoogleAuthService` lets the Google Sign-In plugin read this web
client from the generated `default_web_client_id` resource. There is no separate
Dart default client ID overriding Android's Firebase configuration.
`--dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com`
overrides it; an empty override uses the native configuration. The value must
be a **Web application** OAuth
client. Android OAuth clients register the package/certificate pair in Google
Cloud and are not passed as `serverClientId`.

This flow sends a Google **ID token** directly to
`https://biholive.com/api/v1/auth/login/` under the legacy field
`server_auth_code`. It does not call Firebase Authentication. The backend must
verify the Google token's signature, expiry, issuer, and audience; its allowed
audience must include the web client used by the installed build.

## Investigation on October 5, 2026

Both debug and Play Store login were reported as failing. The local keystores
and existing debug APK were inspected with `keytool` and `apksigner`:

| Certificate | SHA-1 | Current JSON snapshot |
| --- | --- | --- |
| Local debug keystore and debug APK | `86:BB:E8:E9:DE:BE:13:13:EB:F1:C3:84:05:D5:25:BA:99:6D:FF:DA` | No matching Android OAuth client |
| Local release keystore, alias `upload` | `82:E7:79:C4:F7:AC:3C:DB:CE:25:2D:2D:69:F7:0D:AE:21:2E:EF:48` | Matching Android OAuth client |
| Other Android OAuth client in JSON | `59:46:29:22:0A:2D:1E:95:CD:47:7A:69:5D:CD:6B:85:5A:E9:96:16` | Present; corresponding local key not identified |

Debug SHA-256:

```text
4A:19:2C:A7:D2:00:95:0C:E9:B9:19:6A:BA:C2:1A:C0:D2:E3:6C:F0:61:AB:42:43:7D:1B:03:03:95:46:DE:39
```

Local release/upload SHA-256:

```text
43:7E:5A:1F:5E:F0:6F:43:07:A2:EF:51:B8:A6:C5:89:59:75:AB:95:FE:11:B4:33:29:50:1C:37:87:93:05:2F
```

The fingerprints supplied as the Play Store certificate match the local
release/upload key exactly. Confirm them against **App signing key certificate**
in Play Console's App integrity page. The upload key and the Play app signing
key can differ; local key inspection cannot establish the certificate used by
a Play-installed APK.

The former Dart default web client matched the current JSON and generated
debug resources. Android now reads the native configuration directly, so a
future JSON update cannot leave an older hardcoded default in Dart. This does
not resolve server-side certificate ownership or backend audience mismatches.
Earlier release instructions named web client
`107414380235-s5cmfapqeosv3r63d6g51e377vp4sdkq.apps.googleusercontent.com`.
If the backend still expects that older audience, it will reject tokens issued
for the current client. The backend source/configuration is not in this
workspace, so this is a condition to check, not a confirmed backend failure.

Live Firebase SHA registration could not be read: the existing Firebase CLI
account received HTTP 403 `PERMISSION_DENIED` from `apps:android:sha:list`.
Consequently, absence from the local JSON establishes a snapshot mismatch,
not proof of the live Cloud registration state. No Android device was connected
for runtime logs. All four existing `test/google_login_test.dart` tests passed
with platform/backend fakes; they do not validate Google's live OAuth setup.

## Debug SHA registration conflict

Adding debug SHA-1 `86:BB:E8:E9:DE:BE:13:13:EB:F1:C3:84:05:D5:25:BA:99:6D:FF:DA`
was subsequently reported to fail because another project already has an
Android OAuth client for this SHA-1 and package name. Google requires this pair
to be unique across Firebase and Google Cloud projects. This confirms a
registration conflict, but does not identify the owning project or explain
the Play Store build's failure.

Inspect Android OAuth clients in Google Cloud's APIs & Services > Credentials,
starting with the earlier OAuth project number `107414380235`. That project is
a lead from this app's history, not a verified owner of the conflicting client.
Match both `com.biholive.net` and the complete debug SHA-1.

If the matching client is unused and registration should move to
`biholive-a0045`, remove that specific SHA from the old Firebase Android app,
then verify the corresponding Android OAuth client was removed in Cloud. For
a client managed directly in Cloud, remove the matching Android client there.
Only after resolving that ownership conflict, register the fingerprint in the
current project and download the updated JSON. Retaining the old OAuth client
requires coordinating its project's web client and the backend token audience.

Firebase also documents external-client safelisting for Firebase Authentication.
That setting does not change this app's direct-backend token verification.
See [Google's conflict resolution guide](https://support.google.com/firebase/answer/6401008)
for locating the owning project and the supported resolution paths.

## Complete the configuration

1. In Firebase project `biholive-a0045`, select Android app `com.biholive.net`
   under Project settings. Register the local debug SHA-1 and SHA-256 above.
   Also retain the release key fingerprints and register the actual Play app
   signing fingerprints if they differ. Verify the corresponding Android OAuth
   clients in the same Google Cloud project as the web client. Editing a hash
   in the local JSON does not register an OAuth client on Google's servers.
2. If managing OAuth through Firebase, enable the Google provider in
   Authentication > Sign-in method, then download the updated
   `google-services.json` into `android/app/`. This app still uses its own
   backend for the login session.
3. Confirm the backend's allowed Google ID-token audience includes
   `976789308527-a7ie4kfg7le4ae4aoasdpgfafg9pqcga.apps.googleusercontent.com`.
   If retaining the old OAuth project, coordinate the Android registrations,
   app's `GOOGLE_SERVER_CLIENT_ID`, and backend audience together.
4. Rebuild and install after changing the native configuration; hot reload
   does not update Android resources or an already published Play build:

   ```sh
   flutter build apk --debug
   adb install -r build/app/outputs/flutter-apk/app-debug.apk
   ```

   To inspect any APK's signing certificate:

   ```sh
   "$ANDROID_SDK_ROOT/build-tools/36.0.0/apksigner" verify --print-certs /path/to/app.apk
   ```

   A Play build containing an older compiled web client needs a new app release;
   adding a missing server-side certificate registration alone can be tested
   against an existing build.
5. Reproduce login while reading app diagnostics:

   ```sh
   adb logcat -v time 'flutter:I' '*:S' | rg 'GOOGLE-AUTH'
   ```

   - `canceled` after selecting an account, or `clientConfigurationError`:
     inspect package, actual signing SHA-1, and web client registration first.
     Credential Manager can report configuration problems as cancellation.
   - `Google returned an ID token for audience ...`: the Google account step
     succeeded. The audience is a public OAuth client ID; the token and other
     account claims are not logged. Compare this ID with the backend's allowed
     audience for the installed build.
   - `Backend rejected login: HTTP ...`: Google returned an ID token and the
     backend rejected the session request. Inspect backend verification and
     the debug API logger's redacted response; HTTP status alone does not prove
     an audience mismatch.
   - `Login failed at device` or `session`: inspect device ID retrieval or
     the returned session shape respectively.

Verify account selection, cancellation, successful login, and retry after a
backend/network error on both installed builds. The app stays on login until
the backend returns a valid session. Share the `GOOGLE-AUTH` error and backend
HTTP status rather than ID tokens or session tokens.

The next repository version is `1.0.2+2`. Play requires a version code greater
than every previously uploaded version; if `2` has already been used, set a
higher build number before creating the upload bundle. A successful release
build verifies compilation and signing, not live Google login. Confirm login
using an internal Play test before rollout.

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
