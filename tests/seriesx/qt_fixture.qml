import QtQuick
import Veyra

Item {
    id: fixture
    width: 700
    height: 900
    property alias quick: controls
    property alias engineState: testEngine
    property alias consoleState: testXbox

    QtObject {
        id: testEngine
        property bool fgEnabled: false
        property string fgBackendName: "xess"
        property var fgBackendChoices: [
            {id:"vfg", label:"VFG", disabled:false},
            {id:"xess", label:"XeSS", disabled:false}
        ]
        property int fgMultiplier: 4
        property int contentRate: 0
        property bool fgAutoMultiplierEnabled: true
        property bool fgAdaptive: true
        property int vfgQuality: 2
        property bool vfgAutoRegulate: true
        property bool hudLock: false
        property bool pacingRepair: false
        property bool srEnabled: false
    }
    QtObject {
        id: testXbox
        property var state: ({requestedHeight:1080, streaming:false, stream:({})})
        function set(name,value) {
            if (name !== "resolution" || (value !== 1080 && value !== 1440)) return false
            state = Object.assign({},state,{requestedHeight:value})
            return true
        }
    }
    SeriesXQuickControls {
        id: controls
        anchors.fill: parent
        backend: testEngine
        xboxModel: testXbox
        xboxState: testXbox.state
    }
}
