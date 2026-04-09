# iOS Publishing Guide

## Apple Developer Portal Links

**1. Certificates** — https://developer.apple.com/account/resources/certificates/list
Where you create your developer "ID card" that proves you're authorized to publish apps to Apple.

**2. Identifiers** — https://developer.apple.com/account/resources/identifiers/list
Where you register your app with a unique name so Apple can recognize it among millions of other apps.

**3. Provisioning Profiles** — https://developer.apple.com/account/resources/profiles/list
Where you create a file that ties your certificate and app together — basically telling Apple "this developer is allowed to build this specific app."

**4. App Store Connect** — https://appstoreconnect.apple.com/apps
Your app's control panel. This is where you set up the store listing, upload screenshots, and submit the app for Apple's review.

**5. Apple Account (App-Specific Passwords)** — https://account.apple.com/account/manage
Where you generate a special password that allows the automated system to upload builds on your behalf without needing your actual login.

**6. SSL Converter (optional, rarely needed)** — https://www.sslshopper.com/ssl-converter.html
A tool to convert certificate formats. You'll likely never need this.

---

## What to keep handy and share with any future developer

- The **email address** you use to sign in to your Apple Developer account
- The **app-specific password** generated from item 5 above
- The **certificate file** (.p12) downloaded from item 1 and the **password you set** when exporting it
- The **provisioning profile** file downloaded from item 3

Keep these saved somewhere safe. Any developer you work with in the future can use them right away to build and publish updates to your app without starting from scratch.
