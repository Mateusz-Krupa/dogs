# Building and uploading a TestFlight build

Verified working end-to-end on 2026-10-22 (build 0.1.0, first upload).

## Prerequisites

- Apple Development + Apple Distribution certificates for team `G5RD7F6C65`
  (auto-created by `-allowProvisioningUpdates` on first run; no manual
  developer.apple.com clicking needed).
- App Store Connect API key `.p8` at:
  `~/.appstoreconnect/private_keys/AuthKey_VD5X8VD796.p8`
  - Key ID: `VD5X8VD796`
  - Issuer ID: `8e5da999-2d70-439a-9a2f-016fea57c2c3`
  - The `.p8` itself is NEVER in this repo, never in chat, never read by
    tooling — only `altool` opens it.
- Xcode app account signed in with the same Apple ID (for profile updates).

## Pipeline (from repo root)

```sh
# 1. Archive (real device signing; CI-friendly, no GUI)
xcodebuild archive -project Pettrainer.xcodeproj -scheme Pettrainer \
  -destination 'generic/platform=iOS' -allowProvisioningUpdates \
  -archivePath build-archive/Pettrainer -derivedDataPath build-archive-dd

# 2. Export App Store IPA (re-signs with Apple Distribution)
xcodebuild -exportArchive -archivePath build-archive/Pettrainer.xcarchive \
  -exportPath build-archive/export \
  -exportOptionsPlist /tmp/export-options.plist -allowProvisioningUpdates
# export-options.plist: method=app-store-connect, teamID=G5RD7F6C65,
# signingStyle=automatic, compileBitcode=false, manageAppVersionAndBuildNumber=true,
# uploadSymbols=true

# 3. Validate + upload (both non-interactive with the API key)
xcrun altool --validate-app -f build-archive/export/Pettrainer.ipa -t ios \
  --apiKey VD5X8VD796 --apiIssuer 8e5da999-2d70-439a-9a2f-016fea57c2c3
xcrun altool --upload-app  -f build-archive/export/Pettrainer.ipa -t ios \
  --apiKey VD5X8VD796 --apiIssuer 8e5da999-2d70-439a-9a2f-016fea57c2c3
```

`manageAppVersionAndBuildNumber=true` means Xcode owns the build number —
re-exporting the same archive keeps versions sane; bump
`MARKETING_VERSION` in the project for user-visible releases.

## After upload (App Store Connect)

1. Processing takes ~5–30 min; Apple sends “Binary uploaded”/“Processing”
   emails. Only then the build appears under TestFlight.
2. **Internal testing**: instant, no review — good for the on-device gate
   (airplane mode, kill/relaunch, set resume).
3. **External testing** (e.g. group `chatty-pet-external`) requires once:
   App Information → Privacy Policy URL (app collects nothing; “Data Not
   Collected” in App Privacy), and the Age Rating questionnaire. Then the
   build needs Beta App Review (hours–1 day).

## Known gotchas (hit in practice)

- Simulator builds thin `Assets.car` per destination; validate icon contents
  against a `generic/platform=iOS` build (`assetutil --info …/Assets.car`),
  never a simulator one.
- App icon: full classic set required (120×120 iPhone, 152×152 iPad,
  83.5@2x = **167px**, 1024 marketing) plus `INFOPLIST_KEY_CFBundleIconName`.
  Regenerate the 1024 master via `IconArtworkTests` (sentinel
  `Documents/reicon.flag` in the app container).
- The `.xcarchive` stays local (`build-archive/`, git-ignored).
