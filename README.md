<p align="center">
  <img src="docs/icon.png" width="160" alt="CopyLogFix18 icon">
</p>

# CopyLogFix18

<p align="center"><strong>CopyLogFix18 is a rootless iOS jailbreak tweak that fixes the confirmed `pasted` crash caused by CopyLog 1.7.x on iOS 18.</strong></p>

- Package: `com.burc334.copylogfix18`
- Version: `1.0.0`
- Tested: iOS 18.4.1 (Dopamine 3, roothide) on iPhone 11 Pro Max
- Builds: rootless (`iphoneos-arm64`) and roothide (`iphoneos-arm64e`)
- License: MIT

## Compatibility

| Build | Architecture | Compatibility |
|---|---|---|
| roothide | `iphoneos-arm64e` | Tested on iOS 18.4.1 (Dopamine 3, roothide) |
| rootless | `iphoneos-arm64` | Expected to work on iOS 16+ rootless jailbreaks |

The tweak requires iOS 16.0 or later and CopyLog 1.7 or 1.7.1. The roothide build was tested on iOS 18.4.1. The rootless build is expected to work on iOS 16+ rootless jailbreaks. Where the endpoint already implements `-persistentIdentifier`, the tweak is a no-op.

## What it fixes

CopyLog 1.7/1.7.1 injects `CopyLogPasteD.dylib` into the system `pasted` daemon. That dylib hooks:

```text
-[PBCFUserNotificationPasteAnnouncer requestAuthorizationForPaste:replyHandler:]
```

The hook calls `-persistentIdentifier` on the paste's source and destination endpoints without checking that the endpoint implements it. On iOS 18.4.1 those endpoints can be `DRPasteAnnouncementContinuityEndpoint`, which does not implement the selector. The result is:

```text
-[DRPasteAnnouncementContinuityEndpoint persistentIdentifier]: unrecognized selector
```

and a crash loop in `pasted`.

CopyLogFix18 adds a non-matching `-persistentIdentifier` implementation to `DRPasteAnnouncementContinuityEndpoint` in `pasted`, but only if the class does not already implement it. CopyLog's `-isEqualToData:` comparison then returns false and falls through to the system implementation instead of crashing. The method is added at load time and retried when a new dyld image is loaded, in case the endpoint class lives in a lazily loaded image.

No CopyLog classes are swizzled and no CopyLog files are replaced.

## What it does not fix

This is not a general iOS 18 compatibility patch for CopyLog.

- It only addresses the confirmed `pasted` crash above.
- It does not modify CopyLog's SpringBoard UI, keyboard daemon, edit menu, rich content, notifications, history, favorites, search, or scroll performance.
- It does not replace CopyLog and contains no CopyLog code or assets.
- Other crash logs or broken features need separate evidence and separate fixes.

## Requirements

- CopyLog 1.7 or 1.7.1 installed.
- iOS 16.0 or later.
- A jailbroken device with Substrate or ElleKit injection.
- The roothide build for roothide devices; the rootless build for rootless devices.
- The tweak is filtered to the `pasted` executable only.

## Install

### Sileo

Add `https://burc334.github.io/apt/` in Sileo, then install CopyLogFix18.

### Manual

1. Install CopyLog 1.7 or 1.7.1 first.
2. Download the deb matching your jailbreak:
   - roothide: `com.burc334.copylogfix18_1.0.0_iphoneos-arm64e.deb`
   - rootless: `com.burc334.copylogfix18_1.0.0_iphoneos-arm64.deb`
3. Install it with Sileo, Zebra, or Filza.
4. Respring. The package's `postinst` restarts `pasted`; CopyLog itself also restarts `pasted` on install.

## Test

1. Install CopyLog 1.7.1.
2. Install CopyLogFix18.
3. Respring.
4. Copy and paste normally across apps.
5. Trigger Universal Clipboard/Handoff if possible.
6. Use apps that present the iOS paste prompt.
7. Watch CrashReporter for new `pasted` crashes, especially the `DRPasteAnnouncementContinuityEndpoint` selector.

A successful test is no new `pasted` crash of that type. It does not prove that every CopyLog feature works on iOS 18; that requires separate feature checks.

## Build

```sh
export THEOS=$HOME/theos
make clean package FINALPACKAGE=1
./tools/make-roothide.sh
```

The rootless deb is written to `packages/`. The roothide script converts the latest rootless package to `iphoneos-arm64e`. Release artifacts are copied to `builds/`.

## Verification

SHA-256 checksums are published in `SHA256SUMS.txt` with the GitHub release. Verify the downloaded deb before installing it.

## Support

Open an issue on the [GitHub repository](https://github.com/burc334/CopyLogFix18/issues). Include your iOS version, jailbreak, device model, CopyLog version, and CopyLogFix18 version.

## License

MIT

AI-assisted development with DeepSeek-V4.1-Flash-1017.
