import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import vm from "node:vm";

const datePickerPath = new URL("./date_picker.js", import.meta.url);
let datePickerSource = await readFile(datePickerPath, "utf8");

datePickerSource = datePickerSource
  .replace(/^import[\s\S]*?from "@floating-ui\/dom";\n/m, "")
  .replace("export default class DatePicker", "class DatePicker")
  .concat("\nglobalThis.DatePicker = DatePicker;\n");

const context = {
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

vm.runInNewContext(datePickerSource, context, { filename: datePickerPath.pathname });
const DatePicker = context.DatePicker;

function option({ date, selected }) {
  const attributes = new Map([
    ["aria-selected", selected],
    ["aria-disabled", "false"],
    ["aria-hidden", "false"],
  ]);

  return {
    dataset: { date, outsideMonth: "false" },
    style: { display: "" },
    setAttribute(name, value) {
      attributes.set(name, value);
    },
    getAttribute(name) {
      return attributes.get(name) ?? null;
    },
    getBoundingClientRect() {
      return { bottom: 1, top: 0 };
    },
  };
}

function keyboardHook(items) {
  const focusedItems = [];
  const popup = {
    dataset: { gridNavigation: "calendar" },
    scrollTop: 0,
    getBoundingClientRect() {
      return { bottom: 100, top: 0 };
    },
  };

  const hook = Object.create(DatePicker.prototype);

  Object.assign(hook, {
    expanded: true,
    currentIndex: 0,
    focus_selected: true,
    popup,
    getNavigableItems() {
      return items;
    },
    focusElement(item) {
      focusedItems.push(item);
    },
    scrollItemIntoView() {},
    focusedItems,
  });

  return hook;
}

test("keyboard focus preserves server-rendered aria-selected state", () => {
  const selectedDate = option({ date: "2026-08-18", selected: "true" });
  const nextDate = option({ date: "2026-08-19", selected: "false" });
  const items = [selectedDate, nextDate];
  const hook = keyboardHook(items);
  let prevented = false;

  DatePicker.prototype.handleArrowNavigation.call(hook, {
    key: "ArrowRight",
    preventDefault() {
      prevented = true;
    },
  });

  assert.equal(prevented, true);
  assert.equal(hook.currentIndex, 1);
  assert.equal(selectedDate.getAttribute("aria-selected"), "true");
  assert.equal(nextDate.getAttribute("aria-selected"), "false");
  assert.equal(selectedDate.getAttribute("tabindex"), "-1");
  assert.equal(nextDate.getAttribute("tabindex"), "0");
  assert.deepEqual(hook.focusedItems, [nextDate]);
});
