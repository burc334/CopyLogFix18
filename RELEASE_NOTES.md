# CopyLogFix18 1.0.0

CopyLogFix18 1.0.0 is the first public release of the iOS 18 compatibility fix
for CopyLog 1.7.x.

## Highlights

- Prevents the confirmed `pasted` daemon crash caused by
  `DRPasteAnnouncementContinuityEndpoint`.
- Adds the missing `-persistentIdentifier` method only when the class does not
  already implement it.
- Retries the check when a new dyld image loads.
- Filtered to the `pasted` executable only.
- No preference pane, icon, or configuration.
- Rootless and RootHide packages.

## Compatibility

| Build | Architecture | Compatibility |
|---|---|---|
| RootHide | `iphoneos-arm64e` | Tested on iOS 18.4.1 (Dopamine 3, RootHide) |
| Rootless | `iphoneos-arm64` | Expected to work on iOS 16+ rootless jailbreaks |

Tested on iOS 18.4.1 (Dopamine 3, RootHide) on iPhone 11 Pro Max. The tweak
requires iOS 16.0 or later and CopyLog 1.7 or 1.7.1. The rootless build is
expected to work on iOS 16+ rootless jailbreaks. Where the endpoint already
implements `-persistentIdentifier`, the tweak is a no-op.

## Scope

This release fixes the confirmed `pasted` crash only. It does not modify
CopyLog's SpringBoard UI, keyboard daemon, edit menu, rich content,
notifications, history, favorites, search, or scroll performance. It is not a
general iOS 18 compatibility patch and does not replace CopyLog.

## Requirements

- CopyLog 1.7 or 1.7.1 installed.
- iOS 16.0 or later.
- A jailbroken device with Substrate or ElleKit injection.
- The RootHide build for RootHide devices; the rootless build for rootless
  devices.

## Assets

- `com.burc334.copylogfix18_1.0.0_iphoneos-arm64e.deb`
- `com.burc334.copylogfix18_1.0.0_iphoneos-arm64.deb`
- `SHA256SUMS.txt`

## Install

1. Install CopyLog 1.7 or 1.7.1 first.
2. Download the deb matching your jailbreak.
3. Install it with Sileo, Zebra, or Filza.
4. Respring. The package's `postinst` restarts `pasted`.

## Verification

Verify the downloaded deb against `SHA256SUMS.txt` before installing it.

## Notes

This release uses GitHub Releases and the GitHub Pages depiction. No APT
repository is required.
