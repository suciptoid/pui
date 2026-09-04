import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import vm from "node:vm";

const loadingPath = new URL("./loading.js", import.meta.url);
let loadingSource = await readFile(loadingPath, "utf8");

loadingSource = loadingSource
  .replace(/^import[^\n]*\n/m, "")
  .replace("export default class LoadingBar", "class LoadingBar")
  .concat("\nglobalThis.LoadingBar = LoadingBar;\n");

const scheduler = {
  nextId: 1,
  timers: new Map(),
  frames: new Map(),
  setTimeout(callback) {
    const id = this.nextId++;
    this.timers.set(id, callback);
    return id;
  },
  clearTimeout(id) {
    this.timers.delete(id);
  },
  requestAnimationFrame(callback) {
    const id = this.nextId++;
    this.frames.set(id, callback);
    return id;
  },
  cancelAnimationFrame(id) {
    this.frames.delete(id);
  },
  flushTimers() {
    for (const [id, callback] of [...this.timers]) {
      this.timers.delete(id);
      callback();
    }
  },
  flushFrames(now = 16) {
    for (const [id, callback] of [...this.frames]) {
      this.frames.delete(id);
      callback(now);
    }
  },
  reset() {
    this.timers.clear();
    this.frames.clear();
  },
};

const listeners = new Map();
const window = {
  addEventListener(type, callback) {
    listeners.set(type, callback);
  },
  removeEventListener(type, callback) {
    if (listeners.get(type) === callback) {
      listeners.delete(type);
    }
  },
};

const context = {
  ViewHook: class ViewHook {},
  cancelAnimationFrame: scheduler.cancelAnimationFrame.bind(scheduler),
  clearTimeout: scheduler.clearTimeout.bind(scheduler),
  performance: { now: () => 0 },
  requestAnimationFrame: scheduler.requestAnimationFrame.bind(scheduler),
  setTimeout: scheduler.setTimeout.bind(scheduler),
  window,
};

vm.runInNewContext(loadingSource, context, { filename: loadingPath.pathname });
const LoadingBar = context.LoadingBar;

function mount() {
  const progressStyle = {
    transition: "",
    width: "0%",
    widthWrites: 0,
  };
  const style = new Proxy(progressStyle, {
    set(target, property, value) {
      if (property === "width") {
        target.widthWrites += 1;
      }
      target[property] = value;
      return true;
    },
  });
  const progressEl = {
    offsetHeight: 0,
    style,
  };
  const hook = new LoadingBar();
  hook.el = {
    dataset: { delay: "0" },
    querySelector: (selector) => (selector === "#loadingbar-progress" ? progressEl : null),
  };
  hook.mounted();

  return { hook, progressEl };
}

test.afterEach(() => {
  scheduler.reset();
  listeners.clear();
});

test("destroyed cancels a pending delayed start", () => {
  const { hook } = mount();

  listeners.get("phx:page-loading-start")();
  hook.destroyed();
  scheduler.flushTimers();

  assert.equal(scheduler.frames.size, 0);
});

test("destroyed cancels the active animation frame", () => {
  const { hook, progressEl } = mount();

  listeners.get("phx:page-loading-start")();
  scheduler.flushTimers();
  scheduler.flushFrames();

  const writesBeforeDestroy = progressEl.style.widthWrites;
  hook.destroyed();
  scheduler.flushFrames();

  assert.equal(progressEl.style.widthWrites, writesBeforeDestroy);
});

test("destroyed cancels the delayed reset", () => {
  const { hook, progressEl } = mount();
  hook.progress = 10;

  hook._hide();
  const writesBeforeDestroy = progressEl.style.widthWrites;
  hook.destroyed();
  scheduler.flushTimers();

  assert.equal(progressEl.style.width, "100%");
  assert.equal(progressEl.style.widthWrites, writesBeforeDestroy);
  assert.equal(hook.progress, 100);
});
