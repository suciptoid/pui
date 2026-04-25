import Popover from "./popover";
import Select from "./select";
import LoadingBar from "./loading";
import Tooltip from "./tooltip";
import FlashGroup from "./flash";
import Tabs from "./tabs";
import Sidebar from "./sidebar";

export const Hooks = {
  "PUI.LoadingBar": LoadingBar,
  "PUI.Popover": Popover,
  "PUI.Select": Select,
  "PUI.Tabs": Tabs,
  "PUI.Tooltip": Tooltip,
  "PUI.FlashGroup": FlashGroup,
  "PUI.Sidebar": Sidebar,
};

export { Popover, Select, LoadingBar, Tabs, Tooltip, FlashGroup, Sidebar };
