# AgnosticOTP — Privacy Policy

**Effective date:** 27 June 2026
**Publisher:** Agnostic Security

## The short version

**AgnosticOTP collects no data. None.** There are no accounts, no analytics, no
telemetry, no crash reporting, no advertising, and no tracking of any kind. The
app does not "call home." Your two-factor secrets and codes stay on your device.

## No data collection

We do not collect, store, transmit, sell, or share any personal data or usage
data. We have no servers that receive anything from the app, because the app
never sends anything.

## No network communication

The app makes **no network connections.** On Android it ships **without the
`INTERNET` permission**, so it is technically incapable of transmitting your
data. The only time information leaves your device is when **you** explicitly
create an encrypted backup and choose where to save it (see *Backups* below).

App updates are delivered solely through the **app store's** standard update
mechanism (Google Play / Apple App Store). The app itself does not check for,
download, or report anything.

## Your secrets stay on your device

TOTP secrets you add are stored **encrypted on your device**, protected by a
hardware-backed key (Android Keystore / StrongBox where available; iOS Secure
Enclave) that requires your **biometric** to unlock. Secrets are never
transmitted off the device by the app.

## Backups (you control them)

If you choose to back up, the app encrypts your accounts **on your device** with
AES-256-GCM under a key derived from a **Recovery Key that only you hold**. The
encrypted file is then handed to your operating system's share/save dialog so
**you** can store it on a cloud of your choice (iCloud, Google Drive, Proton,
Files, etc.). That cloud only ever receives an **opaque encrypted file** — never
your secrets, and never your Recovery Key. We never receive it and cannot read
it (zero-knowledge). If you lose your Recovery Key, no one — including us — can
recover the backup.

## Permissions we use, and why

- **Camera** — only to scan authentication QR codes, processed entirely on your
  device. Images are not stored or transmitted.
- **Biometric (fingerprint / face)** — only to unlock the app. Biometric data is
  handled by your operating system; the app never sees or stores it.

We do not request internet, location, contacts, microphone, or any other
sensitive permission.

## Third parties

The app contains **no third-party analytics or advertising SDKs.** On-device
components (such as the QR-code scanner) operate locally and, with no network
access on Android, cannot transmit anything.

## Children

The app collects no data from anyone, including children.

## Changes to this policy

If this policy changes, the updated version will be published at this location
with a new effective date.

## Contact

Questions about privacy: **privacy@agnosticsec.com**
