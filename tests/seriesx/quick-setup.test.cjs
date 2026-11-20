const fs = require("node:fs");
const vm = require("node:vm");
const assert = require("node:assert/strict");
const source = fs.readFileSync("qml/Veyra/SeriesXQuickSetup.js", "utf8").replace(/^\.pragma library\s*$/m, "");
function fixture(choices) {
    const api = {
        fgEnabled: false, fgBackendChoices: choices, fgBackendName: "xess",
        fgMultiplier: 4, contentRate: 0, fgAutoMultiplierEnabled: true,
        fgAdaptive: true, vfgQuality: 2, vfgAutoRegulate: true,
        srEnabled: true
    };
    const context = {api};
    vm.createContext(context);
    vm.runInContext(source, context);
    return context;
}
{
    const c = fixture([{id: "vfg", disabled: false}, {id: "xess", disabled: false}]);
    assert.equal(c.applyThirtyToSixty(c.api).ok, true);
    assert.equal(c.api.fgBackendName, "vfg");
    assert.equal(c.api.fgMultiplier, 2);
    assert.equal(c.api.contentRate, 5);
    assert.equal(c.api.fgEnabled, true);
    assert.equal(c.api.vfgQuality, 1);
    assert.equal(c.api.fgAutoMultiplierEnabled, false);
    assert.equal(c.api.srEnabled, true);
    c.disableInterpolation(c.api);
    assert.equal(c.api.fgEnabled, false);
    assert.equal(c.api.contentRate, 0);
}
{
    const c = fixture([{id: "vfg", disabled: true}, {id: "xess", disabled: false}]);
    assert.equal(c.applyThirtyToSixty(c.api).ok, true);
    assert.equal(c.api.fgBackendName, "xess");
}
{
    const c = fixture([]);
    assert.equal(c.applyThirtyToSixty(c.api).ok, false);
    assert.equal(c.api.fgEnabled, false);
    assert.equal(c.api.fgMultiplier, 4);
    assert.equal(c.api.contentRate, 0);
}
{
    const c = fixture([{id: "vfg", disabled: false}]);
    Object.defineProperty(c.api, "fgMultiplier", {
        configurable: true, get() { return 4; }, set(_) { /* reject unsupported multiplier */ }
    });
    assert.equal(c.applyThirtyToSixty(c.api).ok, false);
    assert.equal(c.api.fgEnabled, false);
    assert.equal(c.api.contentRate, 0);
}
console.log("PASS: VFG, fallback, unsupported GPU, settings rollback, and unrelated settings preservation");
