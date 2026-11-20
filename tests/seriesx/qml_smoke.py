"""Load the Series X QML component and exercise its buttons in real Qt 6.

Does not authenticate or connect a console and is not a native Windows engine build.
"""
import os
import sys
from pathlib import Path
os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
from PySide6.QtCore import QObject, QMetaObject, Qt, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlEngine, QQmlComponent

root = Path(__file__).resolve().parents[2]
app = QGuiApplication(sys.argv[:1])
engine = QQmlEngine()
engine.addImportPath(str(root / "qml"))
component = QQmlComponent(engine)
component.loadUrl(QUrl.fromLocalFile(str(root / "tests/seriesx/qt_fixture.qml")))
errors = [e.toString() for e in component.errors()]
if errors or not component.isReady():
    raise AssertionError("QML compile/load failed:\n" + "\n".join(errors))
fixture = component.create()
if fixture is None:
    raise AssertionError("QML create failed:\n" + "\n".join(e.toString() for e in component.errors()))
app.processEvents()
quick = fixture.property("quick")
backend = fixture.property("engineState")
assert quick is not None and backend is not None, "Expected bound controls and fake backend"
assert backend.property("fgEnabled") is False
assert QMetaObject.invokeMethod(quick, "applyPreset", Qt.ConnectionType.DirectConnection)
app.processEvents()
assert backend.property("fgEnabled") is True, "Preset failed to enable FG"
assert backend.property("fgBackendName") == "vfg", "Preset did not select VFG"
assert backend.property("contentRate") == 5, "Preset did not enable 60->30 dedup"
assert backend.property("fgMultiplier") == 2, "Preset did not select 2x"
button = quick.findChild(QObject, "xbox-quick-original")
assert button is not None, "Original button missing"
assert QMetaObject.invokeMethod(button, "clicked", Qt.ConnectionType.DirectConnection)
app.processEvents()
assert backend.property("fgEnabled") is False, "Original did not disable FG"
assert backend.property("contentRate") == 0, "Original did not disable dedup"
print("PASS: Qt6 QML instantiated; preset and Original button signals mutate bound settings")
fixture.deleteLater()
