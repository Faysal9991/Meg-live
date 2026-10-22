# Dashboard socket integration

Implemented against `MOBILE_DEVELOPER_HANDOFF.pdf` dated 18 October 2026.

The dashboard uses one connection to the configured backend's
`/ws/livekit-streaming/livekit_streamings/<device_id>/<device_name>/?<user.uid>`.
Both device segments are normalized to letters, digits and underscores. The
live-room socket URL returned by the profile API remains separate.

## Expected request behavior

| Trigger | HTTP requests |
| --- | --- |
| First online dashboard load | Initial profile, banners and live-room list; gifts if not cached |
| Healthy dashboard left open | No room-list or ranking polling |
| Socket reconnect or return from background | One profile and live-room recovery; simultaneous requests share the in-flight work |
| Ranking screen opens or refreshes | Uses shared socket state; no additional ranking request on a supported backend |
| Explicit home refresh | Banners and live-room list |
| Older backend without ranking events | One fallback attempt per missing stream per authenticated session, after a five-second grace period |

Once a ranking stream has delivered any snapshot, it never uses its REST
fallback during that session, including while reconnecting. The live-room
20-second presence heartbeat remains: it updates room presence and has no
documented socket replacement. Local animation timers do not fetch APIs.
If the socket package exhausts its retries during a long outage, the dashboard
starts another socket attempt after 30 seconds. Logout and disposal cancel it.

## Verification on a deployed backend

1. Open the dashboard and leave it idle for at least one minute. Confirm the
   room-list endpoint does not repeat every ten seconds. Confirm all three
   rankings arrive inside `message` without ranking HTTP requests.
2. Send older and duplicate revisions for each ranking type. They must not
   change the list. Send a newer empty list; it must clear the existing rows.
   Host scores use `gift_diamonds`; contributor scores use
   `diamonds_contributed`; agency scores use `total_hosts_diamonds`.
3. Disconnect and reconnect. Retained rankings show reconnecting until their
   fresh snapshots arrive. Lower revisions from the new connection are valid.
   There must be no ranking HTTP recovery requests.
4. Background and resume the app. Confirm profile recovery happens and missed
   room changes are reconciled. Repeated connectivity notifications must not
   duplicate socket listeners or start a fetch loop.
5. Recharge a buyer. The reseller's profile and wallet must remain associated
   with the reseller; the buyer receives the returned level and wallet through
   `load_profile`. Lower and null levels must apply safely. No client-side
   level thresholds or coin credits are calculated.
6. Double-tap recharge, reject it with 204/400, and simulate a timeout. There
   must be one transfer POST, no local award, and no automatic POST retry.
   Uncertain results recover both profiles and history before ending loading.
7. Sign out or switch accounts while a request/device lookup is pending. Old
   responses and listeners must not restore the previous session's state.

The handoff states that the new backend fields/events were not yet deployed.
Confirm the backend migrations and Django/Celery restarts with the backend
owner before end-to-end production validation. This mobile change does not
deploy or alter the backend.
