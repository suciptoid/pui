import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import vm from "node:vm";

const selectPath = new URL("./select.js", import.meta.url);
let selectSource = await readFile(selectPath, "utf8");

selectSource = selectSource
  .replace(/^import[\s\S]*?from "@floating-ui\/dom";\n/m, "")
  .replace("export default class Select", "class Select")
  .concat("\nglobalThis.Select = Select;\n");

const context = {
  Event,
  ViewHook: class ViewHook {},
  autoUpdate() {},
  computePosition() {},
  flip() {},
  getOverflowAncestors() {},
  hide() {},
  offset() {},
  shift() {},
  size() {},
};

vm.runInNewContext(selectSource, context, { filename: selectPath.pathname });
const Select = context.Select;

test("selectItem writes and dispatches change for an empty-string value", () => {
  const dispatchedEvents = [];
  const hiddenInput = {
    value: "previous-value",
    dispatchEvent(event) {
      dispatchedEvents.push(event);
    },
  };
  const hook = {
    hiddenInput,
    setSelectedItem() {},
    updatePlaceholder() {},
    closePopover() {},
    focusElement() {},
  };

  Select.prototype.selectItem.call(hook, { dataset: { value: "" } });

  assert.equal(hiddenInput.value, "");
  assert.equal(dispatchedEvents.length, 1);
  assert.equal(dispatchedEvents[0].type, "change");
  assert.equal(dispatchedEvents[0].bubbles, true);
});

for (const [label, attributes, hidden, display] of [
  ["disabled", { "aria-disabled": "true" }, false, ""],
  ["aria-hidden", { "aria-hidden": "true" }, false, ""],
  ["natively hidden", {}, true, ""],
  ["locally filtered", {}, false, "none"],
]) {
  test(`handlePopupClick ignores ${label} options`, () => {
    let selectedItem;
    const item = {
      hidden,
      style: { display },
      getAttribute(name) {
        return attributes[name] ?? null;
      },
    };
    const hook = {
      popup: { contains: (candidate) => candidate === item },
      selectItem(candidate) {
        selectedItem = candidate;
      },
    };
    const event = { target: { closest: () => item } };

    Select.prototype.handlePopupClick.call(hook, event);

    assert.equal(selectedItem, undefined);
  });
}

test("handlePopupClick selects an available option", () => {
  let selectedItem;
  const item = {
    hidden: false,
    style: { display: "" },
    getAttribute() {
      return null;
    },
  };
  const hook = {
    popup: { contains: (candidate) => candidate === item },
    selectItem(candidate) {
      selectedItem = candidate;
    },
  };
  const event = { target: { closest: () => item } };

  Select.prototype.handlePopupClick.call(hook, event);

  assert.equal(selectedItem, item);
});
