# Security Policy

## Reporting a vulnerability

Please report security issues **privately** — do not open a public issue for anything exploitable.

- **Preferred:** GitHub → the **Security** tab → **Report a vulnerability** (private security advisory) on this repository.
- **Email:** zakaria@buzzjective.com

Include what you found, how to reproduce it, and the affected version or commit. You'll get an acknowledgement within a few days. Please give a reasonable window to ship a fix before any public disclosure.

## Do not include a user's words

Reed's threat model is unusual: the app holds the phrases a person writes — sometimes phrases that imply an adversary who has access to their phone or accounts — and its exported crash log can contain the exact text a user typed. **Never include a user's phrases, an exported crash log, or vocalization text in a report, screenshot, or attachment.** If a report needs sample data, use invented, neutral phrases. A leaked report is itself a privacy incident.

## Scope

In scope:

- The app's data-at-rest posture (device-only storage, backup exclusion).
- Anything that would cause Reed to make a network request, gain the `INTERNET` permission, or leak on-device data off the device.
- Supply-chain concerns in the resolved dependency tree (see the audit in [`pubspec.yaml`](pubspec.yaml)).
- The signing / release integrity of published builds.

Out of scope:

- Behaviour of the device's **system text-to-speech engine**, which is a separate app under its own identity and permissions. Reed selects only voices that declare they need no network, but it cannot inspect or control that engine.
- Social-engineering, physical-access, or lost-device scenarios beyond the backup-exclusion mitigation already documented in the [privacy policy](https://reed.applander.io/privacy).

## Supported versions

Reed is pre-1.0 and in limited testing. Only the latest `main` and the most recent tagged build receive fixes.

| Version | Supported |
|---|---|
| `main` (latest) | ✅ |
| older tags | ❌ |

## Our commitments

- Secret scanning and push protection are enabled on this repository; automated dependency alerts and security fixes are on.
- No analytics, crash-reporting SDK, or telemetry ships in the app — there is no server-side data store to breach, by design.
