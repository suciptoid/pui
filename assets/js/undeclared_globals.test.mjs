import assert from "node:assert/strict";
import { readFile, readdir } from "node:fs/promises";
import test from "node:test";

// ES modules are always strict mode: assigning to an undeclared identifier at
// module scope throws a ReferenceError that breaks the whole bundle at load
// time (e.g. `State = {...}` in loading.js). This test fails on any column-0
// bare assignment in the hook sources, which would become exactly such a
// ReferenceError once bundled.
const jsDir = new URL(".", import.meta.url);
const files = (await readdir(jsDir)).filter(
  (file) =>
    file.endsWith(".js") &&
    !file.endsWith(".test.mjs") &&
    !file.endsWith(".mjs"),
);

const bareAssignment = /^[A-Za-z_$][A-Za-z0-9_$]*\s*=\s*[^=]/;

for (const file of files) {
  const source = await readFile(new URL(file, jsDir), "utf8");

  test(`${file} has no undeclared top-level assignments`, () => {
    const matches = source
      .split("\n")
      .map((line, index) => ({ line, number: index + 1 }))
      .filter(({ line }) => bareAssignment.test(line));

    assert.deepEqual(
      matches,
      [],
      `undeclared top-level assignments in ${file} (strict-mode ReferenceError at bundle load): ${matches
        .map((m) => `${m.number}: ${m.line}`)
        .join("; ")}`,
    );
  });
}
