# iOS Publishing Guide

## Apple Developer Portal Links

**1. Certificates** — https://developer.apple.com/account/resources/certificates/list
Where you create your developer "ID card" that proves you're authorized to publish apps to Apple.

**2. Identifiers** — https://developer.apple.com/account/resources/identifiers/list
Where you register your app with a unique name so Apple can recognize it among millions of other apps.

Two identifiers are required:
- `vpn.free.com` — the main app (with Network Extensions + Personal VPN capabilities)
- `vpn.free.com.network-extension` — the VPN tunnel extension (with Network Extensions capability)

**3. Provisioning Profiles** — https://developer.apple.com/account/resources/profiles/list
Where you create a file that ties your certificate and app together.

Two profiles are required:
- `vpnfreecom` — for the main app (`vpn.free.com`)
- `vpnfreecomnetworkextension` — for the network extension (`vpn.free.com.network-extension`)

**4. App Store Connect** — https://appstoreconnect.apple.com/apps
Your app's control panel. This is where you set up the store listing, upload screenshots, and submit the app for Apple's review.

**5. Apple Account (App-Specific Passwords)** — https://account.apple.com/account/manage
Where you generate a special password that allows the automated system to upload builds on your behalf without needing your actual login.

---

## GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `REPO_ACCESS_TOKEN` | GitHub PAT with repo access |
| `CERTIFICATES_P12` | Base64-encoded .p12 certificate |
| `CERTIFICATES_P12_PASSWORD` | Password for the .p12 file |
| `KEYCHAIN_PASSWORD` | Any password (used to create a temp keychain) |
| `PROVISIONING_PROFILE` | Base64-encoded main app provisioning profile |
| `PROVISIONING_NETWORK_PROFILE` | Base64-encoded network extension provisioning profile |
| `ENV_FILE` | Environment variables (must include `BASE_URL=...`) |
| `APPLE_ID` | Apple Developer email |
| `APP_SPECIFIC_PASSWORD` | App-specific password from Apple |

## What to keep handy and share with any future developer

- The **email address** you use to sign in to your Apple Developer account
- The **app-specific password** generated from item 5 above
- The **certificate file** (.p12) downloaded from item 1 and the **password you set** when exporting it
- Both **provisioning profile** files downloaded from item 3
- The **GitHub secrets** listed above

Keep these saved somewhere safe. Any developer you work with in the future can use them right away to build and publish updates to your app without starting from scratch.
