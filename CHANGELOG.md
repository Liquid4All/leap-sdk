# Changelog

Release notes for the Liquid LEAP SDK Swift Package Manager distribution. This repository hosts the SPM `Package.swift` and binary XCFramework releases of the SDK; the underlying Kotlin Multiplatform source lives at [Liquid4All/leap-android-sdk](https://github.com/Liquid4All/leap-android-sdk) and the Maven Central distribution is `ai.liquid.leap:*`.

Each release links to the upstream commit and the leap-android-sdk PR that produced the XCFrameworks. For longer-form narrative and migration guides, see the [LEAP SDK changelog page](https://liquid.ai/deployment/on-device/leap-sdk-changelog) in the docs.

## v0.10.6 — 2026-05-12

iOS Swift-surface unification on top of v0.10.5. iOS `ModelDownloader` (the Swift class formerly known as `LeapModelDownloader`) reaches parity with the cross-platform `LeapDownloader` — every entry point routes file transfer through `URLSession` and hands off to the loader.

**Source:** leap-android-sdk `main` @ commit [`cac3d06`](https://github.com/Liquid4All/leap-android-sdk/commit/cac3d0663b0caf3030682a13fc3b86ea5af01cae) — PR [#254](https://github.com/Liquid4All/leap-android-sdk/pull/254).

**New iOS API on `ModelDownloader`:**

- `loadModel(modelName:, quantizationType:, options:, generationTimeParameters:, forceDownload:, downloadProgress:)` — downloads (when needed) and loads in one call; transfer registers in `queryStatus`, cancellable via `requestStopDownload`, continues across backgrounding when constructed with `sessionConfiguration: .backgroundSessionConfiguration(withIdentifier:)`.
- `loadModel(manifestUrl:, options:, generationTimeParameters:, forceDownload:, downloadProgress:)` — same flow keyed by a manifest URL.
- `loadSimpleModel(model: ModelSource, options:, generationTimeParameters:, downloadProgress:)` — sideload from explicit paths or URLs.
- `forceDownload: Bool = false` on all three load methods.
- Resource-lookup helpers: `getModelResourceFolder(...)`, `getCachedManifest(...)`, `getCachedFilePath(...)`, `resolve(...)`, `deleteModelFile(...)`.
- `requestDownloadModel(manifestUrl:, forceDownload:)` overload.

**Breaking iOS changes** (Android API surface unchanged):

- **Swift class rename — `LeapModelDownloader` → `ModelDownloader`.** A `@ObjCName(swiftName = "ModelDownloader")` annotation on the Kotlin source resolves the class-vs-module name collision that prevented `extension LeapModelDownloader { ... }` from compiling and made `let downloader = LeapModelDownloader()` uninstantiable from Swift in 0.10.5.
- **Parameter labels renamed** across the iOS `ModelDownloader` surface — `model:` / `quantization:` → `modelName:` / `quantizationType:` on every method. Every loader on every platform now shares the same labels.
- **`LeapModelDownloader` SPM library product is now single-target** — it no longer bundles the `LeapSDK` target. `import LeapModelDownloader` re-exports every `LeapSDK` Kotlin type. Apps with both products on the same target hit a build-time `#error` from the LMD umbrella header; opt out via `LEAP_DUAL_IMPORT_ALLOW=1` in `OTHER_CFLAGS`.
- **`LeapModelDownloader.xcframework` is now a dynamic framework** (was static in 0.10.5). SPM applies Embed & Sign automatically; manual integrators must switch to "Embed & Sign". The XCFramework now also bundles the inference-engine dylibs (`libinference_engine.dylib`, `libinference_engine_llamacpp_backend.dylib`, `libie_zip.dylib`) under `Frameworks/` with an `@loader_path/Frameworks` LC_RPATH.

**New Swift conveniences:**

- `ModelDownloader()`, `ModelDownloader(sessionConfiguration:)`, `ModelDownloader(config:)` SKIE-bundled convenience inits — restore the parameterless / single-arg forms that 0.10.5's ObjC export stripped.
- `LeapDownloaderConfig()` parameterless convenience init mirroring the Kotlin defaults.

**Fixes:**

- `getAvailableDiskSpace()` previously returned `null` on every Apple platform (NSNumber cast issue) — now reports the real free-space figure.
- `requestDownloadModel(forceDownload: false)` short-circuits only when both the cached manifest *and* every resource it references are present on disk.
- Cached-file lookup uses Ktor URL parsing for fragments / query strings.

**XCFramework assets (SPM):** `LeapSDK`, `LeapModelDownloader`, `LeapOpenAIClient`, `LeapUi`.

## v0.10.5 — 2026-05-11

First point release after the 0.10.4.x cascade. Headlines: streaming load progress over the Android Leap Model Service AIDL path, the `useMmap` knob on `ModelLoadingOptions`, and parameter-name cleanup on `LeapDownloader.loadModel` so it matches `LeapModelDownloader.loadModel`.

**Source:** leap-android-sdk `main` @ commit [`e2349a4`](https://github.com/Liquid4All/leap-android-sdk/commit/e2349a44dcd94c575fb8455cc1f00e9f6b671b0f).

**Breaking changes (Kotlin):**

- **`ModelLoadingOptions.cacheDir: String?` → `cacheOptions: EngineOptions.CacheOptions?`** — KV cache config moves to a bounded-LRU value with explicit `enabled` master switch, per-tier caps (`maxEntriesDisk`, `maxEntriesMemory`, `maxBytesMemory`), and optional `diskDisabled = true` for memory-only mode. Migrate via the `ModelLoadingOptions.cacheOptions(path = ...)` factory.
- **`LeapDownloader.loadModel(modelName, quantizationSlug, modelLoadingOptions, …)` → `loadModel(modelName, quantizationType, options, …)`** — parameter renames bring `LeapDownloader` in line with `LeapModelDownloader`. Same rename applies to `loadSimpleModel` and `loadModelFromManifestUrl`.
- **`progress` is now nullable** (`progress: ((ProgressData) -> Unit)? = null`) — pass `null` to opt out.

**New features:**

- `ModelLoadingOptions.useMmap: Boolean? = null` ([#248](https://github.com/Liquid4All/leap-android-sdk/pull/248)) — exposes the engine's `use_mmap` toggle (on by default since v0.10.4). On Swift, `LiquidInferenceEngineOptions` gained a matching `.with(useMmap:)` builder.
- **Leap Model Service streamed load progress** ([#249](https://github.com/Liquid4All/leap-android-sdk/pull/249)) — `LeapModelDownloader.loadModel`'s `progress` callback now fires for service-side downloads.
- **CI hardening** ([#246](https://github.com/Liquid4All/leap-android-sdk/pull/246)) — release/auto-review workflows pin third-party actions by SHA, verify `llvm-mingw` cross-toolchain by SHA-256, drop unnecessary GitHub token scopes, stop persisting GPG armor to disk during Maven Central publish.
- **Maven Central signing fix** ([#253](https://github.com/Liquid4All/leap-android-sdk/pull/253)) — decode `\n` escapes in `signingInMemoryKey` when delivered via env var.

**Fixes / refresh:**

- Apple `LeapModelDownloader` internal slot names switched from `quantizationSlug` → `quantizationType` for consistency. Public Swift label names (`model:` / `quantization:`) unchanged at v0.10.5.
- Vendor `liquid.h` header refresh for Linux/MinGW K/N targets.

## v0.10.4.5 — 2026-05-08

Engine ABI fix release. SPM consumers should bump to this version.

**Source:** leap-android-sdk PR [#243](https://github.com/Liquid4All/leap-android-sdk/pull/243), commit `162be15`.

- Engine pin advanced to `v26.02.1-146-g777faf0dbb` — `liquid_string_destroy` now correctly frees the C string buffer (`CString::from_raw(*s as *mut c_char)`) instead of the Rust slot (`Box::from_raw(s)`). Closes the K/N + Linux `free(): invalid pointer` SIGABRT in `InferenceEngineModelRunner.kt:66`.
- Linux runtime smoke (`EngineRuntimeSmokeTest`) now asserts the engine reports failure on a missing model path — guards against silent-success regressions.
- `NativeLibLoader` cleanup: stdout warnings moved to `System.err`; loader stays kotlin-stdlib-only.

## v0.10.4.4 — 2026-05-07

K/N link-time `--allow-shlib-undefined` fix for Linux consumers. No API changes.

**Source:** leap-android-sdk PR [#243](https://github.com/Liquid4All/leap-android-sdk/pull/243), commit `9df7f1b` (branch `fix/kn-allow-shlib-undefined`).

## v0.10.4.3 — 2026-05-07

iOS/macOS Swift convenience surface for `cacheOptions`.

**Source:** leap-android-sdk PR [#243](https://github.com/Liquid4All/leap-android-sdk/pull/243), commit `d59181f`.

- `LiquidInferenceEngineManifestOptions(cacheOptions: ..., contextSize: 4096)` now works with native Swift types — previously the convenience init dropped `cacheOptions` and forced consumers to the verbose Obj-C designated init with `KotlinUInt(unsignedInt:)` wrapping.
- New `with(cacheOptions:)` builders on `LiquidInferenceEngineOptions` and `LiquidInferenceEngineManifestOptions`.
- New `LiquidCacheOptions.enabled(path:)` static factory — Swift analog of `ModelLoadingOptions.cacheOptions(path:)`.
- Internal: centralized `liquid_inference_engine_cache_options_t` cinterop wiring — `Engine.createFromOptions` and `InferenceEngineModelRunner` collapsed their duplicated 9-line setup blocks into a shared `MemScope.allocCacheOptions(co)` helper.

(v0.10.4.2 was staged to Sonatype but never released; superseded by this build.)

## v0.10.4.1 — 2026-05-07

Vendor pin refresh — bumps the inference engine to `v26.02.1-142-gb4aa080538`. No public API changes.

**Source:** leap-android-sdk PR [#243](https://github.com/Liquid4All/leap-android-sdk/pull/243), commit `9e7cef0b`.

The new vendor pin (39 inference_engine commits vs `-103-`) adds Strategy B chain-prefix replay (snapshot at N-1 + re-decode last token) for cold/warm bit-determinism and generalizes the Android backend native loader to Linux + Windows desktop (`dladdr` POSIX / `GetModuleHandleEx`+`FindFirstFile` Windows). A shared `maybe_init_executorch_submodules` composite action auto-detects `LIQUID_BUILD_EXECUTORCH` from CMake presets to skip XNNPACK + nested executorch fetches when the matrix has executorch off.

## v0.10.4 — 2026-05-06

First stable release with the bounded-LRU `CacheOptions` API and mmap-by-default model loading.

**Source:** leap-android-sdk PR [#243](https://github.com/Liquid4All/leap-android-sdk/pull/243).

- **Bounded-LRU `CacheOptions` API** across JVM, Android, Kotlin/Native, Apple, and wasmJs.
- **`use_mmap=true` is now the engine default** (via vendored IE pin `v26.02.1-79+`). Model weights are memory-mapped instead of `read(2)`-ed into a heap buffer. Lower private RSS, faster cold load, faster warm reloads, and graceful behavior under memory pressure on mobile.
- K/N Linux link fix (`--allow-shlib-undefined` for `libinference_engine.so` against modern glibc).
- Dynamic vendor pipeline + `DT_NEEDED`-based shipped-libs verify; `inference_engine` RUNPATH = `$ORIGIN` cascade for Linux/Windows shared vendor libs.
- `NativeLibLoader` cross-platform load fixes (resource extraction + Windows pre-load topo-retry).
- Three release-gate smokes (Linux K/N, Apple SwiftPM consumer, Windows JVM) wired into CI.

## v0.10.1 — 2026-04-29

Additive fix release for Linux/MinGW Kotlin/Native consumers. Apple/SPM consumers see no API or behavior changes vs v0.10.0.

**Source:** leap-android-sdk `main` @ commit `07bfa6a`.

- `leap-sdk` Linux/MinGW K/N artifacts on Maven Central now publish a `-natives.zip` classifier containing the runtime `.so` / `.dll` libraries.
- New `ai.liquid.leap.nativelibs` Gradle plugin auto-wires the natives ZIP into consumer K/N executables.
- `leap-openai-client` now publishes Linux/MinGW K/N klibs.

## v0.10.0 — 2026-04-28

Initial Kotlin Multiplatform unification release. The previously-separate Android SDK (`ai.liquid.leap:*` Maven) and iOS SDK (`Liquid4All/leap-ios` Swift package) collapse into a single source tree.

**Source:** leap-android-sdk `main` @ commit `b54b363`.

**SPM URL change:** point Swift Package Manager at `https://github.com/Liquid4All/leap-sdk.git` (not the deprecated [`leap-ios`](https://github.com/Liquid4All/leap-ios) repo). CocoaPods removed.

**Breaking changes for iOS consumers:**

- Minimum deployment target raised: **iOS 17.0, macOS 15.0** (was iOS 15.0 / macOS 12.0).
- Toolchain: Xcode 16, Swift 6.0.

**Five SPM products / four Maven artifacts:**

| SPM product | Maven artifact | Purpose |
|---|---|---|
| `LeapSDK` | `ai.liquid.leap:leap-sdk` | Core inference + conversation API |
| `LeapModelDownloader` | `ai.liquid.leap:leap-model-downloader` | Hosted / manifest-based model fetch |
| `LeapOpenAIClient` | `ai.liquid.leap:leap-openai-client` | OpenAI-compatible cloud chat client (new) |
| `LeapUI` | `ai.liquid.leap:leap-ui` | Voice assistant widget — Compose Multiplatform (new) |
| `LeapSDKMacros` | _(Swift only)_ | `@Generatable` / `@Guide` constrained-generation macros |

**Major additions over 0.9.x:**

- **OpenAI-compatible cloud client** ([#176](https://github.com/Liquid4All/leap-android-sdk/pull/176), [#181](https://github.com/Liquid4All/leap-android-sdk/pull/181)) — `LeapOpenAIClient` ships in the same release as `LeapSDK` for hybrid on-device + cloud routing.
- **Voice assistant widget** ([#180](https://github.com/Liquid4All/leap-android-sdk/pull/180)) — `LeapUI` Compose Multiplatform module with animated orb, mic button, and state-machine-driven recording / generation / playback.
- **Leap Model Service (Android)** ([#221](https://github.com/Liquid4All/leap-android-sdk/pull/221), [#226](https://github.com/Liquid4All/leap-android-sdk/pull/226)) — optional shared service that hosts loaded models across apps.
- **New Kotlin/Native targets** — Linux x86_64 + aarch64 ([#184](https://github.com/Liquid4All/leap-android-sdk/pull/184)), Windows x86_64 ([#186](https://github.com/Liquid4All/leap-android-sdk/pull/186)), wasmJs preview ([#196](https://github.com/Liquid4All/leap-android-sdk/pull/196)).
- **Sideloading models from explicit paths** — `LeapDownloader.loadSimpleModel(...)` and `LeapModelDownloader.loadSimpleModel(...)` skip the LEAP Model Library manifest.
- **iOS background downloads** — `ModelDownloader(sessionConfiguration:)` accepts `URLSessionConfiguration?`.
- **`autoDetectCompanionFiles: Bool = true`** on `Leap.load(url:options:)` picks up companion files next to the model.
- **Swift compatibility layer** ([#155](https://github.com/Liquid4All/leap-android-sdk/pull/155), [#174](https://github.com/Liquid4All/leap-android-sdk/pull/174), [#182](https://github.com/Liquid4All/leap-android-sdk/pull/182)) keeps 0.9.x call sites compiling.
- **`onEnum(of:)`** — SKIE-bridged sealed-class switching for Kotlin enums and sealed hierarchies.
- **`ChatMessageContent` static factories** — `.text(...)`, `.fromJPEGData(_:)`, `.fromWAVData(_:)`, `.image(url:)`, `.audio(data:format:)`, `.fromFloatSamples(_:sampleRate:channelCount:)`, plus iOS-only `.fromUIImage(_:)`.
- **Builder-style options** — `LiquidInferenceEngineOptions.with(cacheOptions:)`, `GenerationOptions().with(temperature:)`, etc.
- **`topK` and `rngSeed` on `GenerationOptions`** ([#212](https://github.com/Liquid4All/leap-android-sdk/pull/212)).
- **`enableThinking` on `GenerationOptions`** ([#220](https://github.com/Liquid4All/leap-android-sdk/pull/220)).
- **`injectSchemaIntoPrompt` flag on constrained generation** ([#209](https://github.com/Liquid4All/leap-android-sdk/pull/209)).
- **LFM2.5 Omni model support** ([#229](https://github.com/Liquid4All/leap-android-sdk/pull/229)).
- **Dynamic linking of `inference_engine` on Apple + Linux** ([#232](https://github.com/Liquid4All/leap-android-sdk/pull/232)).

**Known limitation:** Linux/MinGW K/N artifacts have a publishing bug fixed in v0.10.1 — pin to v0.10.1+ for any Kotlin/Native non-Apple target. The Apple SPM distribution from v0.10.0 is fine.

For the full per-PR commit history (78 commits since v0.9.7), see https://github.com/Liquid4All/leap-android-sdk/compare/v0.9.7...v0.10.0.
