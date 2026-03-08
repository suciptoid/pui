import Popover from "./popover";
import Select from "./select";
import LoadingBar from "./loading";
import Tooltip from "./tooltip";
import FlashGroup from "./flash";

export const Hooks = {
  "PUI.LoadingBar": LoadingBar,
  "PUI.Popover": Popover,
  "PUI.Select": Select,
  "PUI.Tooltip": Tooltip,
  "PUI.FlashGroup": FlashGroup,
};

export { Popover, Select, LoadingBar, Tooltip, FlashGroup };
