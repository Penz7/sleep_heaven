# Secret Handling Policy

## Scope

This document defines mandatory secret handling rules for `sleep_heaven`.
It covers Android signing credentials, local development setup, CI setup, and leak response.

## Non-Negotiable Rules

- Never commit secrets to Git history.
- Never print secret values in scripts, build logs, or CI output.
- Never place signing credentials in tracked files.
- Use environment variables in CI.
- Use untracked local files on developer machines.

## Android Release Signing Contract

Release signing requires these values:

- `ANDROID_SIGNING_STORE_FILE`
- `ANDROID_SIGNING_STORE_PASSWORD`
- `ANDROID_SIGNING_KEY_ALIAS`
- `ANDROID_SIGNING_KEY_PASSWORD`
- `ANDROID_SIGNING_PROPERTIES_FILE` (optional override for local properties file path)

### Source Priority

`android/app/build.gradle.kts` must resolve values in this order:

1. Environment variables (required for CI).
2. Local untracked properties file (for developer release builds).

No tracked secret file is required for debug builds.

## Local Developer Setup (Secure)

1. Create a local, untracked properties file (example: `android/key.properties.local`).
2. Put signing values there:

```properties
storeFile=D:/key_store/sleep_heaven/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

3. Ensure the file path and keystore path are ignored by `.gitignore`.
4. Run release build without echoing values in terminal commands.

Local release command:

```bash
flutter build apk --release --dart-define=DEV_MODE=false
```

## CI Setup (Secure)

Configure the signing values as repository or environment secrets:

- `ANDROID_SIGNING_STORE_FILE`
- `ANDROID_SIGNING_STORE_PASSWORD`
- `ANDROID_SIGNING_KEY_ALIAS`
- `ANDROID_SIGNING_KEY_PASSWORD`

CI must inject these values at runtime. Do not persist them to tracked files.

CI release command:

```bash
flutter clean
flutter pub get
flutter build apk --release --dart-define=DEV_MODE=false
```

## Log Sanitization Rules

- Do not use `println` or shell `echo` for signing values.
- Scanner output must use redaction (`--redact`).
- Build failures must mention missing variable names only, never values.

## Leak Incident Response

If any secret is committed or exposed:

1. Revoke and rotate the compromised credential immediately.
2. Replace affected CI/local secrets with new values.
3. Purge exposed files from active branches.
4. Invalidate and regenerate signing material if keystore/password exposure is confirmed.
5. Review recent build logs and commit history for secondary leakage.
6. Document incident timeline and remediation actions.

## Verification Checklist

- Debug build works on fresh clone without committed signing secret files.
- Release build succeeds with env vars or local untracked properties file.
- Secret scan fails on synthetic leaks and passes on clean tree.
- No signing values appear in release build logs.
