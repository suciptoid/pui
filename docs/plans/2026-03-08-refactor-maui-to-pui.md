# Refactor Maui to PUI Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rename the entire library from `maui|Maui|MAUI` to `pui|PUI|PUI` across all source files, configuration, and documentation.

**Architecture:** Systematic find-and-replace across Elixir modules, JavaScript hooks, CSS references, configuration files, and package metadata. Maintain exact same functionality with new naming.

**Tech Stack:** Elixir ~> 1.15, Phoenix LiveView ~> 1.1, JavaScript hooks

---

## Phase 1: Core Library Files

### Task 1: Rename lib/maui.ex to lib/pui.ex

**Files:**
- Modify: `lib/maui.ex` (complete rewrite)
- Create: `lib/pui.ex`
- Delete: `lib/maui.ex`

**Step 1: Read current file**

Run: `cat lib/maui.ex`

**Step 2: Create new lib/pui.ex**

```elixir
defmodule PUI do
  @moduledoc """
  PUI keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from from the database, an external API or others.
  """

  defmacro __using__(_opts) do
    quote do
      import PUI
      import PUI.Input
      import PUI.Button
      import PUI.Dropdown
      import PUI.Alert
      import PUI.Popover
      import PUI.Select
      import PUI.Dialog
      import PUI.Components
    end
  end

  defdelegate popover_base(assigns), to: PUI.Popover, as: :base
end
```

**Step 3: Delete old file**

Run: `rm lib/maui.ex`

**Step 4: Verify**

Run: `ls lib/`

Expected: `pui.ex` exists, `maui.ex` does not exist

**Step 5: Commit**

```bash
git add lib/maui.ex lib/pui.ex
git commit -m "refactor: rename main module from Maui to PUI"
```

---

## Phase 2: Component Modules

### Task 2: Rename lib/maui/ directory to lib/pui/

**Files:**
- Rename: `lib/maui/` → `lib/pui/`

**Step 1: Rename directory**

Run: `mv lib/maui lib/pui`

**Step 2: Verify**

Run: `ls lib/pui/`

Expected: All component files present (alert.ex, button.ex, etc.)

**Step 3: Commit**

```bash
git add -A
git commit -m "refactor: rename lib/maui directory to lib/pui"
```

---

### Task 3: Update alert.ex module name and references

**Files:**
- Modify: `lib/pui/alert.ex`

**Step 1: Read file to find module name**

Run: `head -5 lib/pui/alert.ex`

**Step 2: Replace module name**

Edit: Change `defmodule Maui.Alert` to `defmodule PUI.Alert`

**Step 3: Verify no internal Maui references**

Run: `grep -n "Maui" lib/pui/alert.ex`

Expected: No matches

**Step 4: Commit**

```bash
git add lib/pui/alert.ex
git commit -m "refactor: rename Maui.Alert to PUI.Alert"
```

---

### Task 4: Update button.ex module name and references

**Files:**
- Modify: `lib/pui/button.ex`

**Step 1: Replace module name**

Edit: Change `defmodule Maui.Button` to `defmodule PUI.Button`

**Step 2: Verify**

Run: `grep -n "Maui" lib/pui/button.ex`

Expected: No matches

**Step 3: Commit**

```bash
git add lib/pui/button.ex
git commit -m "refactor: rename Maui.Button to PUI.Button"
```

---

### Task 5: Update components.ex module name and references

**Files:**
- Modify: `lib/pui/components.ex`

**Step 1: Replace module name**

Edit: Change `defmodule Maui.Components` to `defmodule PUI.Components`

**Step 2: Verify**

Run: `grep -n "Maui" lib/pui/components.ex`

Expected: No matches

**Step 3: Commit**

```bash
git add lib/pui/components.ex
git commit -m "refactor: rename Maui.Components to PUI.Components"
```

---

### Task 6: Update dialog.ex module name and references

**Files:**
- Modify: `lib/pui/dialog.ex`

**Step 1: Replace module name**

Edit: Change `defmodule Maui.Dialog` to `defmodule PUI.Dialog`

**Step 2: Verify**

Run: `grep -n "Maui" lib/pui/dialog.ex`

Expected: No matches

**Step 3: Commit**

```bash
git add lib/pui/dialog.ex
git commit -m "refactor: rename Maui.Dialog to PUI.Dialog"
```

---

### Task 7: Update dropdown.ex module name and references

**Files:**
- Modify: `lib/pui/dropdown.ex`

**Step 1: Replace module name**

Edit: Change `defmodule Maui.Dropdown` to `defmodule PUI.Dropdown`

**Step 2: Verify**

Run: `grep -n "Maui" lib/pui/dropdown.ex`

Expected: No matches

**Step 3: Commit**

```bash
git add lib/pui/dropdown.ex
git commit -m "refactor: rename Maui.Dropdown to PUI.Dropdown"
```

---

### Task 8: Update input.ex module name and references

**Files:**
- Modify: `lib/pui/input.ex`

**Step 1: Replace module name**

Edit: Change `defmodule Maui.Input` to `defmodule PUI.Input`

**Step 2: Verify**

Run: `grep -n "Maui" lib/pui/input.ex`

Expected: No matches

**Step 3: Commit**

```bash
git add lib/pui/input.ex
git commit -m "refactor: rename Maui.Input to PUI.Input"
```

---

### Task 9: Update popover.ex module name and references

**Files:**
- Modify: `lib/pui/popover.ex`

**Step 1: Replace module name**

Edit: Change `defmodule Maui.Popover` to `defmodule PUI.Popover`

**Step 2: Verify**

Run: `grep -n "Maui" lib/pui/popover.ex`

Expected: No matches

**Step 3: Commit**

```bash
git add lib/pui/popover.ex
git commit -m "refactor: rename Maui.Popover to PUI.Popover"
```

---

### Task 10: Update select.ex module name and references

**Files:**
- Modify: `lib/pui/select.ex`

**Step 1: Replace module name**

Edit: Change `defmodule Maui.Select` to `defmodule PUI.Select`

**Step 2: Verify**

Run: `grep -n "Maui" lib/pui/select.ex`

Expected: No matches

**Step 3: Commit**

```bash
git add lib/pui/select.ex
git commit -m "refactor: rename Maui.Select to PUI.Select"
```

---

### Task 11: Update remaining component modules

**Files:**
- Modify: `lib/pui/container.ex`
- Modify: `lib/pui/flash.ex`
- Modify: `lib/pui/loading.ex`
- Modify: `lib/pui/menu_button.ex`

**Step 1: Update container.ex**

Edit: Change `defmodule Maui.Container` to `defmodule PUI.Container`

**Step 2: Update flash.ex**

Edit: Change `defmodule Maui.Flash` to `defmodule PUI.Flash`

**Step 3: Update loading.ex**

Edit: Change `defmodule Maui.Loading` to `defmodule PUI.Loading`

**Step 4: Update menu_button.ex**

Edit: Change `defmodule Maui.MenuButton` to `defmodule PUI.MenuButton`

**Step 5: Verify all**

Run: `grep -rn "Maui" lib/pui/`

Expected: No matches

**Step 6: Commit**

```bash
git add lib/pui/*.ex
git commit -m "refactor: rename remaining Maui modules to PUI"
```

---

## Phase 3: Configuration Files

### Task 12: Update mix.exs

**Files:**
- Modify: `mix.exs`

**Step 1: Read file**

Run: `cat mix.exs`

**Step 2: Update module name**

Edit line 1: Change `defmodule Maui.MixProject` to `defmodule PUI.MixProject`

**Step 3: Update app name**

Edit line 6: Change `app: :maui` to `app: :pui`

**Step 4: Update package name**

Edit line 44: Change `name: :maui` to `name: :pui`

**Step 5: Update GitHub link**

Edit line 47: Change `"GitHub" => "https://github.com/suciptoid/maui"` to `"GitHub" => "https://github.com/suciptoid/pui"`

**Step 6: Verify**

Run: `grep -i "maui" mix.exs`

Expected: No matches

**Step 7: Commit**

```bash
git add mix.exs
git commit -m "refactor: update mix.exs from Maui to PUI"
```

---

### Task 13: Update package.json

**Files:**
- Modify: `package.json`

**Step 1: Update name**

Edit line 2: Change `"name": "maui"` to `"name": "pui"`

**Step 2: Update description**

Edit line 4: Change `"description": "Maui Hooks"` to `"description": "PUI Hooks"`

**Step 3: Update module paths**

Edit lines 5-9: Change all `maui.` to `pui.`

```json
"module": "./priv/static/pui.mjs",
"main": "./priv/static/pui.cjs.js",
"exports": {
  "import": "./priv/static/pui.mjs",
  "require": "./priv/static/pui.cjs.js"
}
```

**Step 4: Verify**

Run: `grep -i "maui" package.json`

Expected: No matches

**Step 5: Commit**

```bash
git add package.json
git commit -m "refactor: update package.json from Maui to PUI"
```

---

### Task 14: Update config/config.exs

**Files:**
- Modify: `config/config.exs`

**Step 1: Read file**

Run: `cat config/config.exs`

**Step 2: Update esbuild output paths**

Edit: Change `../priv/static/maui.mjs` to `../priv/static/pui.mjs`
Edit: Change `../priv/static/maui.cjs.js` to `../priv/static/pui.cjs.js`

**Step 3: Verify**

Run: `grep -i "maui" config/config.exs`

Expected: No matches

**Step 4: Commit**

```bash
git add config/config.exs
git commit -m "refactor: update esbuild config output paths"
```

---

## Phase 4: JavaScript Hooks

### Task 15: Update JavaScript hook names

**Files:**
- Modify: `assets/js/hooks/*.ex` (or wherever hooks are defined)

**Step 1: Find hook definition files**

Run: `find assets -name "*.js" -o -name "*.ts"`

**Step 2: Update hook registration**

Edit: Change all `"Maui.` to `"PUI.` in hook definitions

Example changes:
- `"Maui.LoadingBar"` → `"PUI.LoadingBar"`
- `"Maui.Popover"` → `"PUI.Popover"`
- `"Maui.Select"` → `"PUI.Select"`
- `"Maui.Tooltip"` → `"PUI.Tooltip"`
- `"Maui.FlashGroup"` → `"PUI.FlashGroup"`

**Step 3: Verify**

Run: `grep -rn "Maui" assets/js/`

Expected: No matches

**Step 4: Commit**

```bash
git add assets/js/
git commit -m "refactor: rename JS hooks from Maui to PUI"
```

---

### Task 16: Update data-maui attributes to data-pui

**Files:**
- Modify: `assets/js/hooks/*.js`

**Step 1: Find data-maui references**

Run: `grep -rn "data-maui" assets/js/`

**Step 2: Update attributes**

Edit: Change `data-maui` to `data-pui`

Example:
- `data-maui="selected-label"` → `data-pui="selected-label"`

**Step 3: Verify**

Run: `grep -rn "data-maui" assets/js/`

Expected: No matches

**Step 4: Commit**

```bash
git add assets/js/
git commit -m "refactor: rename data-maui attributes to data-pui"
```

---

## Phase 5: Test Files

### Task 17: Rename test directory and update test modules

**Files:**
- Rename: `test/maui/` → `test/pui/`
- Modify: All test files in `test/pui/`

**Step 1: Rename directory**

Run: `mv test/maui test/pui`

**Step 2: Update module names in test files**

For each file in `test/pui/`:
- Edit: Change `defmodule Maui.XxxTest` to `defmodule PUI.XxxTest`
- Edit: Change `import Maui.Xxx` to `import PUI.Xxx`

**Step 3: Verify**

Run: `grep -rn "Maui" test/`

Expected: No matches

**Step 4: Commit**

```bash
git add -A
git commit -m "refactor: rename test directory and modules"
```

---

### Task 18: Update test/phx_live_view_test.exs if exists

**Files:**
- Modify: `test/*_test.exs` (any other test files)

**Step 1: Find all Maui references in tests**

Run: `grep -rn "Maui" test/`

**Step 2: Update all references**

Edit: Change all `Maui` to `PUI`

**Step 3: Verify**

Run: `grep -rn "Maui" test/`

Expected: No matches

**Step 4: Commit**

```bash
git add test/
git commit -m "refactor: update remaining test references"
```

---

## Phase 6: Documentation

### Task 19: Update README.md

**Files:**
- Modify: `README.md`

**Step 1: Read file**

Run: `cat README.md`

**Step 2: Update all references**

Edit: Change all `Maui` to `PUI`
Edit: Change all `maui` to `pui` (except in URLs/links that don't exist yet)

**Step 3: Verify**

Run: `grep -i "maui" README.md`

Expected: No matches (or only historical/changelog references)

**Step 4: Commit**

```bash
git add README.md
git commit -m "docs: update README from Maui to PUI"
```

---

### Task 20: Update guides/usage.md

**Files:**
- Modify: `guides/usage.md`

**Step 1: Read file**

Run: `cat guides/usage.md`

**Step 2: Update all references**

Edit: Change all `Maui` to `PUI`
Edit: Change all `maui` to `pui`

**Step 3: Verify**

Run: `grep -i "maui" guides/usage.md`

Expected: No matches

**Step 4: Commit**

```bash
git add guides/usage.md
git commit -m "docs: update usage guide from Maui to PUI"
```

---

### Task 21: Update AGENTS.md

**Files:**
- Modify: `AGENTS.md`

**Step 1: Read file**

Run: `cat AGENTS.md`

**Step 2: Update all references**

Edit: Change all `Maui` to `PUI`
Edit: Change all `maui` to `pui`

**Step 3: Verify**

Run: `grep -i "maui" AGENTS.md`

Expected: No matches

**Step 4: Commit**

```bash
git add AGENTS.md
git commit -m "docs: update AGENTS.md from Maui to PUI"
```

---

### Task 22: Update doc/ files

**Files:**
- Modify: All files in `doc/`

**Step 1: Find all Maui references**

Run: `grep -rn "Maui\|maui" doc/`

**Step 2: Update all references**

Edit: Change all `Maui` to `PUI`
Edit: Change all `maui` to `pui`

**Step 3: Verify**

Run: `grep -rn "Maui\|maui" doc/`

Expected: No matches

**Step 4: Commit**

```bash
git add doc/
git commit -m "docs: update generated documentation"
```

---

## Phase 7: Demo Application

### Task 23: Update demo/mix.exs

**Files:**
- Modify: `demo/mix.exs`

**Step 1: Read file**

Run: `cat demo/mix.exs`

**Step 2: Update dependency**

Edit: Change `{:maui, path: "../"}` to `{:pui, path: "../"}`

**Step 3: Verify**

Run: `grep -i "maui" demo/mix.exs`

Expected: No matches

**Step 4: Commit**

```bash
git add demo/mix.exs
git commit -m "refactor: update demo dependency to pui"
```

---

### Task 24: Update demo config files

**Files:**
- Modify: `demo/config/dev.exs`
- Modify: `demo/config/config.exs`

**Step 1: Update dev.exs**

Edit: Change `~r"lib/maui/` to `~r"lib/pui/`
Edit: Change `reloadable_apps: [:maui` to `reloadable_apps: [:pui`

**Step 2: Verify**

Run: `grep -i "maui" demo/config/`

Expected: No matches

**Step 3: Commit**

```bash
git add demo/config/
git commit -m "refactor: update demo config files"
```

---

### Task 25: Update demo application files

**Files:**
- Modify: All `demo/lib/app_web/live/*.ex` files

**Step 1: Find all Maui references in demo**

Run: `grep -rn "use Maui\|Maui\." demo/lib/`

**Step 2: Update use statements**

Edit: Change `use Maui` to `use PUI`

**Step 3: Update component references**

Edit: Change all `<Maui.` to `<PUI.`
Edit: Change all `Maui.Components.` to `PUI.Components.`

**Step 4: Verify**

Run: `grep -rn "Maui" demo/lib/`

Expected: No matches

**Step 5: Commit**

```bash
git add demo/lib/
git commit -m "refactor: update demo LiveView files"
```

---

### Task 26: Update demo assets

**Files:**
- Modify: `demo/assets/js/app.js`

**Step 1: Read file**

Run: `cat demo/assets/js/app.js`

**Step 2: Update imports**

Edit: Change `import { Hooks as MauiHooks } from "maui"` to `import { Hooks as PUIHooks } from "pui"`
Edit: Change `...MauiHooks` to `...PUIHooks`

**Step 3: Verify**

Run: `grep -i "maui" demo/assets/`

Expected: No matches

**Step 4: Commit**

```bash
git add demo/assets/
git commit -m "refactor: update demo assets imports"
```

---

### Task 27: Update demo static assets

**Files:**
- Modify: `demo/priv/static/assets/js/app.js`
- Modify: `demo/priv/static/assets/css/app.css`

**Step 1: Update JS bundle**

Run: `grep -l "Maui" demo/priv/static/assets/js/*.js`

Edit: Rebuild or manually update references

**Step 2: Update CSS if needed**

Run: `grep -l "maui" demo/priv/static/assets/css/*.css`

Edit: Update any CSS references

**Step 3: Verify**

Run: `grep -i "maui" demo/priv/static/`

Expected: No matches (or only in hashed filenames)

**Step 4: Commit**

```bash
git add demo/priv/static/
git commit -m "refactor: update demo static assets"
```

---

## Phase 8: Build Outputs

### Task 28: Rebuild assets and update priv/static

**Files:**
- Modify: `priv/static/maui.*` → `priv/static/pui.*`

**Step 1: Run setup**

Run: `mix setup`

Expected: Builds successfully, creates `priv/static/pui.mjs` and `priv/static/pui.cjs.js`

**Step 2: Remove old files**

Run: `rm -f priv/static/maui.*`

**Step 3: Verify**

Run: `ls priv/static/`

Expected: `pui.mjs`, `pui.cjs.js`, `pui.mjs.map`, `pui.cjs.js.map` exist

**Step 4: Commit**

```bash
git add priv/static/
git commit -m "refactor: rebuild assets with PUI naming"
```

---

## Phase 9: Final Verification

### Task 29: Run comprehensive search for remaining Maui references

**Files:**
- All project files

**Step 1: Search all Elixir files**

Run: `grep -rn "Maui\|maui" --include="*.ex" --include="*.exs" .`

Expected: No matches (except in .git, deps, _build)

**Step 2: Search all JavaScript files**

Run: `grep -rn "Maui\|maui" --include="*.js" --include="*.mjs" .`

Expected: No matches (except in .git, deps, _build, node_modules)

**Step 3: Search all config files**

Run: `grep -rn "Maui\|maui" --include="*.json" --include="*.exs" .`

Expected: No matches (except in .git, deps, _build)

**Step 4: Search all markdown files**

Run: `grep -rn "Maui\|maui" --include="*.md" .`

Expected: Only historical/changelog references if any

---

### Task 30: Run tests

**Step 1: Run test suite**

Run: `mix test`

Expected: All tests pass

**Step 2: Fix any failing tests**

If tests fail due to module name issues, update the failing assertions/imports

**Step 3: Verify compilation**

Run: `mix compile`

Expected: No warnings or errors

---

### Task 31: Final commit

**Step 1: Stage all remaining changes**

Run: `git status`

**Step 2: Create final commit**

```bash
git add -A
git commit -m "refactor: complete Maui to PUI renaming"
```

---

## Summary

Total tasks: 31
Estimated time: 2-3 hours
Risk level: Medium (mechanical changes, but many files)

**Post-refactor checklist:**
- [ ] All tests pass
- [ ] Demo app runs correctly
- [ ] Package builds successfully
- [ ] No Maui references remain (except git history)
- [ ] Update GitHub repo name if desired
- [ ] Update any CI/CD pipelines
- [ ] Update hex.pm package metadata
