# Live room controls verification

Automated coverage is in `live_room_join_and_admin_test.dart`,
`guest_call_media_test.dart`, `live_room_session_test.dart`,
`live_room_controls_test.dart`, and `edit_profile_name_test.dart`.

The following checks require physical devices, authenticated accounts, and the
running LiveKit/action-socket backend. They have not been run by the automated
widget tests.

| Scenario | Expected result |
| --- | --- |
| Host opens a viewer's profile or the viewer list | Make room admin is available; selecting it changes to Remove room admin. |
| Assigned admin opens WAITING | Accept and reject controls appear immediately. Revoking admin removes them immediately. |
| Admin accepts an audio/video request | Guest joins with their selected camera state; other participants see the same state. |
| Ordinary viewer opens WAITING | No accept/reject controls. Room admin alone grants no other moderator powers. |
| Viewer enters after an admin was assigned, or reconnects | Admin list synchronizes from the host. |
| Host minimizes while an admin handles requests | Admin permissions and the host's live connection remain active. |
| New live session starts | Previous session's room-admin assignments are cleared. |
| Guest chooses Join audio | Microphone permission is requested; camera permission is not requested. Camera never briefly turns on. |
| Audio guest enables camera from call controls | Camera permission is requested if needed, then video becomes visible. |
| Guest chooses Join video | Camera and microphone are enabled after acceptance. |
| Guest dismisses mode selection | No call request is submitted. |
| Call ends while permissions are being granted | Media does not start after the call has ended. |
| Host, viewer, or guest minimizes and browses Home/Profile/Chat | Live remains connected; Return to live restores the same session and media state. |
| User taps another room or Go Live while a room is active | Existing room is restored before any room state is reset. Leave the current room to enter another. |
| Host ends the stream while viewer is minimized | Floating control disappears, room is disposed, and current browsing page stays open. |
| Save a profile name of 26–50 characters | App submits the full name and backend accepts/persists it. Input stops at 50 user-visible characters. |

Room-admin assignments are scoped to the running session and use reliable
LiveKit data packets with the host's authenticated participant identity. Both
host and admin must run this app version. LiveKit tokens must permit data
publishing; verify assignment and reconnect behavior against the deployed token
service. Existing moderator and King-package permissions are unchanged.

Call requests and acceptance continue through the existing action socket and
calling-group API. No backend schema or API contract has been changed. Verify
the backend's profile name limit is also at least 50 characters.
