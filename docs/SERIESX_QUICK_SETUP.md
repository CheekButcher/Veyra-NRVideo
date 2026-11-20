# Series X Quick Setup (experimental)

## Functionality

- One-click 30-to-60 **interpolation** for 30 FPS gameplay inside a 60 FPS stream. This cannot unlock native game FPS or reduce console response time.
- On an available GPU engine, selects 2x frame generation and 60-to-30 duplicate removal; keeps optional super-resolution settings as-is.
- Experimental 2560x1440 Xbox client dimensions request saved locally. A received-stream statistics display independently reports the actual incoming width/height. Xbox might ignore the request.
- Manual toggles for frame interpolation, duplicate removal, frame-generation provider, HUD protection, pacing repair and super resolution.

## Tests

- Fast offline: `node tests/seriesx/quick-setup.test.cjs`; `python tests/seriesx/check_layout.py`
- Windows with native dependencies: build and run `veyra_xbox_tests` (loopback WebRTC transport checks verify outgoing 1440p metadata).
- Windows Qt Quick Test: `tests/qml/quick/tst_seriesx_quick_controls.qml` with the project's Qt Quick Test runner.

## Required live acceptance tests

1. Sign in using Microsoft's Xbox device-code browser flow; turn on Xbox Remote Features.
2. Connect the Series X, initially at 1080p. Record decoded resolution, stream stability, and controller input.
3. Choose 1440p and **reconnect**. Confirm 2560x1440 in actual stream statistics, not merely the selector.
4. On a game known to render 30 genuine frames each second, click 30 to 60 FPS. Verify output cadence, new interpolated frames, audio sync, HUD artifacts, decoder corruption, and latency on an RTX 3090.
5. Compare with Original/off and repeat at 1080p. Do not upload Xbox tokens or credentials.

The Windows build and real hardware acceptance tests are pending. This repo remains GPL-3.0 licensed, with notices retained.
