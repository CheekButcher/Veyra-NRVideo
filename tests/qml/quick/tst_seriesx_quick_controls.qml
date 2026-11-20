// SPDX-License-Identifier: GPL-3.0-only
import QtQuick
import QtQuick.Layouts
import QtTest
import Veyra

Item {
    id: fixture
    width: 700
    height: 950
    QtObject {
        id: fakeEngine
        property bool fgEnabled: false
        property string fgBackendName: "xess"
        property var fgBackendChoices: [
            {id: "vfg", label: "NVIDIA VFG", disabled: false},
            {id: "xess", label: "XeSS", disabled: false}
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
        id: fakeConsole
        property var state: ({requestedHeight: 1080, streaming: false, stream: ({})})
        function set(name, value) {
            if (name !== "resolution" || (value !== 1080 && value !== 1440)) return false
            state = Object.assign({}, state, {requestedHeight: value})
            return true
        }
    }
    SeriesXQuickControls {
        id: quick
        anchors.left: parent.left
        anchors.right: parent.right
        backend: fakeEngine
        xboxModel: fakeConsole
        xboxState: fakeConsole.state
    }
    TestCase {
        name: "SeriesXQuickControls"
        when: windowShown
        function init() {
            fakeEngine.fgEnabled = false
            fakeEngine.fgBackendName = "xess"
            fakeEngine.contentRate = 0
            fakeEngine.fgMultiplier = 4
            fakeEngine.fgAutoMultiplierEnabled = true
            fakeEngine.fgAdaptive = true
            fakeEngine.srEnabled = false
            fakeConsole.state = {requestedHeight: 1080, streaming: false, stream: ({})}
            quick.result = ""
            quick.advanced = false
            wait(30)
        }
        function test_resolutionRequestStaysRequest() {
            const selector = findChild(quick, "xbox-quick-resolution")
            compare(selector.current, "1080")
            selector.picked("1440")
            compare(fakeConsole.state.requestedHeight, 1440)
            compare(selector.current, "1440")
            verify(findChild(quick, "xbox-quick-actual-stream").text.includes("unknown"))
        }
        function test_oneClickPresetAndOriginal() {
            findChild(quick, "xbox-quick-gta60").clicked()
            compare(fakeEngine.fgBackendName, "vfg")
            compare(fakeEngine.fgEnabled, true)
            compare(fakeEngine.fgMultiplier, 2)
            compare(fakeEngine.contentRate, 5)
            compare(fakeEngine.vfgQuality, 1)
            compare(fakeEngine.srEnabled, false)
            findChild(quick, "xbox-quick-original").clicked()
            compare(fakeEngine.fgEnabled, false)
            compare(fakeEngine.contentRate, 0)
        }
        function test_manualControls() {
            findChild(quick, "xbox-quick-fg").toggled(true)
            compare(fakeEngine.fgEnabled, true)
            findChild(quick, "xbox-quick-dedup").picked("1")
            compare(fakeEngine.contentRate, 1)
            findChild(quick, "xbox-quick-advanced").toggled(true)
            compare(quick.advanced, true)
        }
        function test_actualDimensionsAreNotConfusedWithRequest() {
            fakeConsole.state = {requestedHeight: 1440, streaming: true, stream: ({width: 1920, height: 1080, receivedFps: 59.9, videoMbps: 12.5})}
            const info = findChild(quick, "xbox-quick-actual-stream").text
            verify(info.includes("1920"))
            verify(info.includes("1080"))
            verify(!info.includes("2560"))
        }
    }
}
