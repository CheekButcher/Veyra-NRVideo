"""Parse and link the Series X QML component against an actual Qt 6 runtime.

Does not instantiate the Xbox service, connect a console or run GPU FG.
"""
import os
import sys
from pathlib import Path
os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlEngine, QQmlComponent

root = Path(__file__).resolve().parents[2]
app = QGuiApplication(sys.argv[:1])
engine = QQmlEngine()
engine.addImportPath(str(root / "qml"))
component = QQmlComponent(engine)
component.loadUrl(QUrl.fromLocalFile(str(root / "qml/Veyra/SeriesXQuickControls.qml")))
errors = [e.toString() for e in component.errors()]
if errors or not component.isReady():
    print("QML errors:\n" + "\n".join(errors))
    sys.exit(1)
print("PASS: Series X QML component parsed, imported, and linked by Qt", component.status())
