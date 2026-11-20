from pathlib import Path
root = Path(__file__).resolve().parents[2]
qml = (root / "qml/Veyra/SeriesXQuickControls.qml").read_text(encoding="utf-8")
dialog = (root / "qml/Veyra/XboxSourceDialog.qml").read_text(encoding="utf-8")
qmldir = (root / "qml/Veyra/qmldir").read_text(encoding="utf-8")
source = (root / "src/xbox/WebRtcSession.cpp").read_text(encoding="utf-8")
tests = (root / "tests/xbox/XboxTests.cpp").read_text(encoding="utf-8")
model = (root / "src/ui/XboxModel.cpp").read_text(encoding="utf-8")
assert "SeriesXQuickControls 1.0 SeriesXQuickControls.qml" in qmldir
assert "SeriesXQuickControls {" in dialog
assert all(key in qml for key in (
    "xbox-quick-resolution", "xbox-quick-gta60", "xbox-quick-original",
    "xbox-quick-fg", "xbox-quick-dedup", "xbox-quick-backend",
    "xbox-quick-hud", "xbox-quick-pacing", "xbox-quick-sr",
    "xbox-quick-actual-stream", "root.xboxState.stream.width", "root.xboxState.stream.height"
))
assert "requestedHeight_ = height; saveSettings()" in model
assert '{"horizontal", clientWidth_}' in source
assert "1440p request reaches the Xbox dimensionschanged protocol message" in tests
assert "setClientDimensions(2560, 1440)" in tests
print("PASS: UI-source and Xbox request contract static checks")
