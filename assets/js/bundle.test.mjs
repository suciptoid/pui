import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import vm from "node:vm";

// Smoke test for the published ESM bundle (priv/static/pui.mjs). The bundle is
// evaluated under strict mode, which mirrors how an ESM consumer loads it. Any
// undeclared top-level assignment (e.g. the former `State = {...}` in
// loading.js) throws a ReferenceError here, failing the build.
const bundlePath = new URL("../../priv/static/pui.mjs", import.meta.url);
const source = await readFile(bundlePath, "utf8");

// External imports (phoenix_live_view) and the trailing export list are not
// valid inside a vm script; strip them. Everything else is bundled inline.
const scriptSource = source
  .replace(/^import[^\n]*\n/gm, "")
  .replace(/export \{[\s\S]*?\};/g, "");

// esbuild renames the external ViewHook import per module (ViewHook2,
// ViewHook3, ...); stub any of them so class definitions can evaluate.
const viewHookNames = [...new Set(scriptSource.match(/ViewHook\d*/g) || [])];
const context = Object.fromEntries(viewHookNames.map((name) => [name, class {}]));

test("ESM bundle evaluates under strict mode without throwing", () => {
  assert.doesNotThrow(() => {
    vm.runInNewContext('"use strict";\n' + scriptSource, context, {
      filename: "pui.mjs",
    });
  });
});
