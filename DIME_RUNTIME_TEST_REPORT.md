# Dime runtime test report

**Date:** 2026-11-06
**Branch:** `dime-full-migration`
**Required baseline:** `b52defc` is an ancestor of this branch.

## Build results

| Check | Result |
|---|---|
| Production unsigned iOS build | Passed |
| WidgetKit extension build | Passed |
| Package resolution | Passed |
| QA Dime simulator build | Passed |
| QA Dime simulator installation and launch | Passed |
| Signed physical-device IPA | Not available |

- **Xcode:** 26.6 (`/Applications/Xcode_26.6.app`)
- **Deployment target:** iOS 15.0
- Production build command: `Squirrel_Release`, `Release`, generic iOS destination, `CODE_SIGNING_ALLOWED=NO`.
- Production build run: [42225637327](https://github.com/kosaai/squirrel/actions/runs/42225637327)
- QA simulator run: [42224554948](https://github.com/kosaai/squirrel/actions/runs/42224554948)

The production run built the app and WidgetKit extension, then packaged `Squirrel-unsigned.ipa` successfully. It is an **unsigned artifact and is not installable on a physical iPhone**.

- Unsigned IPA artifact: [Squirrel-unsigned-ipa](https://github.com/kosaai/squirrel/actions/runs/42225637327/artifacts/13504924520)
- Build diagnostics: [Squirrel-build-diagnostics](https://github.com/kosaai/squirrel/actions/runs/42225637327/artifacts/13505248260)
- QA screenshot and launch-log evidence: [Dime-QA-simulator-evidence](https://github.com/kosaai/squirrel/actions/runs/42224554948/artifacts/13505312591)

## Compiler/build fixes verified

The first macOS builds found and the subsequent successful build verified these corrections:

1. Project parsing/package resolution workflow compatibility (`.github/workflows/build-ios.yml`, `Squirrel.xcodeproj/project.pbxproj`).
2. Duplicate Swift output for two `HomeView.swift` files; inactive Dime shell renamed to `DimeHomeView.swift`.
3. Syntax and interpolation errors in migrated Insights, Budget, Templates, and Log sources.
4. iOS 15 compatibility for migrated navigation views.
5. Core Data `Identifiable` access control and the template editor’s incorrect test-resource registration.

The current successful production run still reports existing Core Data inverse-relationship warnings for the newly added schedule/template/budget relationships and existing asset-symbol name warnings. These are warnings, not build failures. They were not changed because changing the model relationships would require a real migration test.

## Isolated Dime QA configuration

`DIME_QA` is a compile-time-only path in `financecontrol/View/ContentView.swift`; without that flag, the existing production `ContentView` path remains active.

The QA workflow (`.github/workflows/dime-qa-simulator.yml`) uses:

- Dime shell entry point with all four tabs and the original custom tab bar.
- An isolated simulator application ID: `dev.squirrelapp.squirrel.dimeqa`.
- A separate QA App Group entitlement: `group.dev.squirrelapp.squirrel.dimeqa`.
- A fresh GitHub-hosted simulator; no user device, user application, or user store was read, changed, or installed over.

The QA run installed and launched the isolated app successfully (`simctl launch` PID `9932`) and captured a screenshot. This verifies compilation, installation, and first launch of the Dime entry point only.

## Runtime test results

| Test | Result | Evidence/limit |
|---|---|---|
| Dime shell launch | Passed | QA run 42224554948 |
| Four-tab shell compiled | Passed | QA Dime build |
| Custom tab bar compiled | Passed | QA Dime build |
| Transaction editor presentation compiled | Passed | QA Dime build |
| Expense/income CRUD | Not run | No UI automation/manual simulator session available |
| Log search/filter/delete | Not run | Same limitation |
| Budget/Insights live refresh | Not run | Same limitation |
| Templates/schedules/duplicate prevention | Not run | Same limitation |
| Arabic/RTL visual review | Not run | Screenshot capture is not an interaction/localization test |
| EUR visual formatting | Not run | No scripted UI assertions |
| Month-end/DST recurrence | Not run | Requires controlled fixtures and assertions |

## Core Data migration results

**Not runtime-tested.** No copies of historical production local stores were supplied or available on the runner. No production store was accessed, migrated, reset, or modified.

Before release, run the migration suite against copied stores from every prior model version and compare expense/category/return counts, amounts, dates, and relationships before/after migration. Also exercise new income, schedule, template, and budget records, category deletion, repeated foreground schedule processing, month-end, and DST cases.

## Signing and installation

No signing certificate, provisioning profile, or legitimate QA App ID provisioning was available. The CI IPA is unsigned and must not be described as installable. A physical-device QA IPA requires an Apple Development/Distribution certificate, a profile that covers the QA app ID and QA App Group (plus the QA widget extension if included), and an archive/export using those credentials.

## Recommendation

**Build and isolated Dime startup are verified. Production release is BLOCKED pending historical-store migration testing and functional UI/runtime coverage listed above.** Do not install the unsigned IPA or enable the Dime path in production.

## Device Dime QA IPA (2026-11-06)

A dedicated iPhoneOS workflow was added at `.github/workflows/dime-qa-device-ipa.yml`. Unlike the previous production workflow, it builds with `DIME_QA`, which selects `DimeQARoot` and `DimeHomeView` in `ContentView.swift`.

- Device build run: [42228617307](https://github.com/kosaai/squirrel/actions/runs/42228617307)
- IPA artifact: [Nafaqat-Dime-QA-Unsigned-IPA](https://github.com/kosaai/squirrel/actions/runs/42228617307/artifacts/13507505440)
- Verification logs: [Nafaqat-Dime-QA-device-verification](https://github.com/kosaai/squirrel/actions/runs/42228617307/artifacts/13505649966)
- Filename: `Nafaqat-Dime-QA-Unsigned.ipa`
- Size: `1,915,331 bytes`
- QA app bundle ID: `dev.squirrelapp.squirrel.dimeqa`
- QA widget bundle ID: `dev.squirrelapp.squirrel.dimeqa.squirrelWidget`

The workflow verified the packaged app binary is `Mach-O 64-bit executable arm64` with iOS platform `2` and minimum iOS `15.0`; it is not a simulator binary. It verified the QA bundle identifiers, `Payload/Nafaqat-Dime-QA.app/Squirrel`, Arabic resources, the Core Data model, and Dime root/tab/editor source wiring. `codesign` reported that the app is not signed.

The same `DIME_QA` root was launched in the simulator and a screenshot was inspected. It visibly shows the Dime Log empty state, original custom four-tab bar, and central add-transaction button: [simulator evidence](https://github.com/kosaai/squirrel/actions/runs/42224554948/artifacts/13505312591).

This IPA is ready for manual signing, not direct installation. Manual signing must sign the app and embedded widget extension with profiles matching the two QA bundle IDs and the QA App Group `group.dev.squirrelapp.squirrel.dimeqa`; do not use production identifiers or entitlements.
