# CopyLogFix18 — testing

## Build 1.0.0 — final metadata release

**Built:** 2026-11-07
**Behavior build installed:** 2026-10-31 on iPhone 11 Pro Max, iOS 18.4.1 (22E252),
Dopamine 3 + RootHide, arm64e
**Final metadata build installed:** 2026-11-07 on the same device; respringed.
**Device / iOS / jailbreak:** iPhone 11 Pro Max, iOS 18.4.1 (22E252),
Dopamine 3 + RootHide, arm64e

**RootHide deb:**
`builds/com.burc334.copylogfix18_1.0.0_iphoneos-arm64e.deb`
SHA-256: `cb1a9ab80e540aefb9a1774a496efbff24d779138215ac836f043c7f09894482`

**Rootless deb:**
`builds/com.burc334.copylogfix18_1.0.0_iphoneos-arm64.deb`
SHA-256: `2c7bcc655536517e3fa04946d8c93121ac008f5f95f17d7a6dd63d840833cbe6`

**Install result:** the behavior build (RootHide, SHA-256
`b1eb19e6c88db7528954fa067d641bd36d376233931f16b9212dc5240a202c8e`) was
installed over CopyLog 1.7.1. The remote hash matched, `pasted` was restarted,
SpringBoard respringed, and no safe mode was observed.
**Log result:** not applicable — the release dylib has no probe or file logging.
**Crash result:** the user reported the fix “seems to be working”; no new
`pasted` crash was reported during the short test. A 24–48 hour CrashReporter
watch has not been recorded.

### Final metadata install — 2026-11-07

The final RootHide package `cb1a9ab80e540aefb9a1774a496efbff24d779138215ac836f043c7f09894482`
was transferred to `/var/mobile/Documents/CopyLogFix18_1.0.0_arm64e_final.deb`.
The remote SHA-256 matched exactly. `dpkg -i` installed it over 1.0.0 and
respringed SpringBoard.

Device state after respring:

```text
com.burc334.copylogfix18  1.0.0  iphoneos-arm64e  ii
SpringBoard: PID 13844, running
pasted:      PID 13847, running
No safe mode observed
```

RootHide re-signed the installed dylib in place. The installed file differs from
the package payload by 40 bytes in the signature/UUID area only; the arm64e
`__text` disassembly and load commands are identical. Installed dylib SHA-256:
`56fbdd0adcd55e8c1b76f68bda3122dc497b321cf550ed7a772e71009f55e8c3`.

### Final metadata rebuild

The source (`CopyLogFix18.m`) is unchanged from the behavior build. The final
rebuild only adds `Depiction` and `SileoDepiction` to `control`, regenerates the
package, and re-signs the RootHide copy. The arm64e `__text` disassembly of the
final dylib is identical to the tested build; only the package metadata,
UUID/signature bytes, and package hash differ.

### Static verification

- Rootless payload: only `CopyLogFix18.dylib` + `CopyLogFix18.plist` under
  `var/jb/Library/MobileSubstrate/DynamicLibraries`.
- RootHide payload: only the same two files under
  `Library/MobileSubstrate/DynamicLibraries`.
- Both dylibs are fat arm64 + arm64e.
- Rootless links Foundation/CoreFoundation/libobjc/libSystem.
- RootHide has the same system dependencies and no stale `@rpath/CydiaSubstrate`
  load command.
- The RootHide dylib uses no Substrate/ElleKit symbols; it is a constructor-only
  fix loaded by the jailbreak's tweak injection. It therefore does not carry a
  substrate load command. This matches the tested build.
- Filter plist targets the `pasted` executable only.
- `Depends: mobilesubstrate, firmware (>= 16.0), me.tomt000.copylog (>= 1.7)`.
- `postinst` and `postrm` both restart `pasted`.
- No preference bundle, icon, launchd job, daemon, probe, or dSYM is present.
- No personal paths, credentials, or session IDs appear in the source or debs.
- No `NSLog` or debug strings are present; only two `os_log` installation
  messages remain.
- `depiction.json` validates; `docs/.nojekyll` is present.

### Test checklist

- [x] RootHide behavior build installs with no dependency error.
- [x] Remote package SHA-256 matches the local artifact.
- [x] `pasted` restarts; SpringBoard resprings; no safe mode.
- [x] User reports the behavior build appears to work.
- [x] Install the final metadata RootHide build and respring.
- [x] Final package hash matched on device; no safe mode.
- [x] SpringBoard and `pasted` running after respring.
- [ ] Normal copy/paste across apps on the final metadata build.
- [ ] Universal Clipboard / Handoff copy-paste.
- [ ] Apps that present the iOS paste prompt.
- [ ] 24–48 hour CrashReporter watch for new `pasted` crashes.
- [ ] Rootless build installed on a rootless device.
- [ ] Confirm the tweak is a no-op on iOS 16/17 where the selector already exists.
- [ ] Full CopyLog feature matrix (history, favorites, search, keyboard gesture,
      edit menu, dictation, notifications) — outside this fix's scope.

### Result / notes

The confirmed crash path is fixed in the RootHide behavior build. The final
metadata package has the same code, and it is now installed and respringed on
the target device with `pasted` running. This release does not certify the rest
of CopyLog on iOS 18.
