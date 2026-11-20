// SPDX-License-Identifier: GPL-3.0-only
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "SeriesXQuickSetup.js" as Quick

ColumnLayout {
    id: root
    required property var backend
    required property var xboxModel
    required property var xboxState
    property string result: ""
    property bool advanced: false
    spacing: 4

    function applyPreset() { result = Quick.applyThirtyToSixty(backend).text }
    function turnOff() { result = Quick.disableInterpolation(backend).text }

    DialogSection { text: qsTr("Series X · Quick setup") }
    DialogGroup {
        VRow {
            label: qsTr("Xbox stream request")
            hint: qsTr("1440p is experimental. Reconnect to apply. Actual stream resolution may remain 1080p.")
            hintBelow: true
            VSeg {
                objectName: "xbox-quick-resolution"
                options: [{id:"1080",label:"1080p"},{id:"1440",label:"1440p"}]
                current: String(root.xboxState.requestedHeight || 1080)
                onPicked: id => root.xboxModel.set("resolution", Number(id))
            }
        }
        VRow {
            label: qsTr("30 FPS game · 60 FPS picture")
            hint: qsTr("Only use when a 60 FPS Xbox stream contains 30 unique source frames.")
            hintBelow: true
            RowLayout {
                spacing: 6
                VButton {
                    objectName: "xbox-quick-gta60"
                    text: qsTr("30 to 60 FPS")
                    primary: true
                    enabled: (root.backend.fgBackendChoices || []).some(o => o.disabled !== true)
                    onClicked: root.applyPreset()
                }
                VButton {
                    objectName: "xbox-quick-original"
                    text: qsTr("Original")
                    onClicked: root.turnOff()
                }
            }
        }
        VRow {
            label: qsTr("Frame interpolation")
            hint: qsTr("Adds frames visually, without making controller response native 60 FPS.")
            VSwitch {
                objectName: "xbox-quick-fg"
                checked: root.backend.fgEnabled
                onToggled: on => root.backend.fgEnabled = on
            }
        }
        VRow {
            label: qsTr("Remove duplicate frames")
            hint: qsTr("60 to 30: only for truly repeated 30 FPS game images. Auto detects repeats.")
            hintBelow: true
            VSeg {
                objectName: "xbox-quick-dedup"
                options: [{id:"0",label:qsTr("Off")},{id:"1",label:qsTr("Auto")},{id:"5",label:"60 to 30"}]
                current: String(Number(root.backend.contentRate) === 5 ? 5 : Number(root.backend.contentRate) > 0 ? 1 : 0)
                onPicked: id => root.backend.contentRate = Number(id)
            }
        }
        VRow {
            label: qsTr("Frame-generation engine")
            hint: qsTr("Unavailable backends remain disabled.")
            VSelect {
                objectName: "xbox-quick-backend"
                options: root.backend.fgBackendChoices || []
                value: (options.find(o => o.id === root.backend.fgBackendName) || {}).label || ""
                onPicked: id => root.backend.fgBackendName = id
            }
        }
        VRow {
            label: qsTr("More options")
            VSwitch {
                objectName: "xbox-quick-advanced"
                checked: root.advanced
                onToggled: on => root.advanced = on
            }
        }
        VRow {
            visible: root.advanced
            label: qsTr("HUD ghosting protection")
            VSwitch {
                objectName: "xbox-quick-hud"
                enabled: root.backend.fgBackendName !== "xess"
                checked: root.backend.hudLock
                onToggled: on => root.backend.hudLock = on
            }
        }
        VRow {
            visible: root.advanced
            label: qsTr("30 FPS pacing repair")
            hint: qsTr("May add a capture refresh of latency.")
            VSwitch {
                objectName: "xbox-quick-pacing"
                enabled: root.backend.fgBackendName !== "xess"
                checked: root.backend.pacingRepair
                onToggled: on => root.backend.pacingRepair = on
            }
        }
        VRow {
            visible: root.advanced
            label: qsTr("Video super resolution")
            hint: qsTr("Upscales received video but never changes Xbox transport resolution.")
            VSwitch {
                objectName: "xbox-quick-sr"
                checked: root.backend.srEnabled
                onToggled: on => root.backend.srEnabled = on
            }
        }
    }
    DialogNote {
        objectName: "xbox-quick-actual-stream"
        text: root.xboxState.streaming && root.xboxState.stream && root.xboxState.stream.height
            ? qsTr("Actual Xbox picture: %1 × %2 · %3 received FPS · %4 Mbps")
                .arg(root.xboxState.stream.width).arg(root.xboxState.stream.height)
                .arg(Number(root.xboxState.stream.receivedFps || 0).toFixed(1))
                .arg(Number(root.xboxState.stream.videoMbps || 0).toFixed(1))
            : qsTr("Actual stream resolution: unknown until connected. 1440p is a request, not a guarantee.")
    }
    DialogNote {
        objectName: "xbox-quick-status"
        visible: root.result.length > 0
        text: root.result
    }
}
