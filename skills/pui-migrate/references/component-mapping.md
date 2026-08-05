# Component Mapping

## Common Replacements

- Generated button helpers -> `PUI.Button.button/1`
- Generated input helpers -> `PUI.Input.input/1`
- Generated flash wrappers -> `PUI.Flash.flash_group/1`
- Local modal wrappers -> `PUI.Dialog.dialog/1`
- Generated layout wrappers -> `PUI.Layout.app_layout/1` plus sidebar/content helpers

## Migration Notes

- Replace in small slices to avoid broad regressions.
- Keep app-specific business copy local; migrate only presentational helpers to PUI.
- Prefer documented component attrs and slots over custom ad-hoc assigns.
