.pragma library
// Interpolation adds pictures, not game simulation frames.
function availableBackend(api, id) {
    return (api.fgBackendChoices || []).some(option => option.id === id && option.disabled !== true)
}
function applyThirtyToSixty(api) {
    const before = {
        fgEnabled: api.fgEnabled, fgBackendName: api.fgBackendName,
        fgMultiplier: api.fgMultiplier, contentRate: api.contentRate,
        fgAutoMultiplierEnabled: api.fgAutoMultiplierEnabled,
        fgAdaptive: api.fgAdaptive, vfgQuality: api.vfgQuality,
        vfgAutoRegulate: api.vfgAutoRegulate
    }
    const order = ["vfg", "xess", "fsr", "dlss", "anr"]
    let chosen = ""
    for (const id of order) if (availableBackend(api, id)) { chosen = id; break }
    if (!chosen) return {ok: false, text: "No supported frame generator detected."}
    function restore() {
        api.fgEnabled = false
        api.fgBackendName = before.fgBackendName
        api.fgMultiplier = before.fgMultiplier
        api.contentRate = before.contentRate
        api.fgAutoMultiplierEnabled = before.fgAutoMultiplierEnabled
        api.fgAdaptive = before.fgAdaptive
        api.vfgQuality = before.vfgQuality
        api.vfgAutoRegulate = before.vfgAutoRegulate
        api.fgEnabled = before.fgEnabled
    }
    api.fgEnabled = false
    api.fgBackendName = chosen
    if (api.fgBackendName !== chosen) {
        restore()
        return {ok: false, text: "Frame-generation backend rejected; original settings restored."}
    }
    api.fgAutoMultiplierEnabled = false
    api.fgAdaptive = false
    api.fgMultiplier = 2
    if (Number(api.fgMultiplier) !== 2) {
        restore()
        return {ok: false, text: "2x frame generation unavailable; original settings restored."}
    }
    api.contentRate = 5
    if (chosen === "vfg") {
        api.vfgQuality = 1
        api.vfgAutoRegulate = false
    }
    api.fgEnabled = true
    if (!api.fgEnabled) {
        restore()
        return {ok: false, text: "Frame generation was rejected; original settings restored."}
    }
    return {ok: true, text: "30-to-60 interpolation enabled (" + chosen.toUpperCase() + "). Verify 30 unique input FPS."}
}
function disableInterpolation(api) {
    api.fgEnabled = false
    api.contentRate = 0
    return {ok: true, text: "Interpolation and duplicate removal disabled."}
}
