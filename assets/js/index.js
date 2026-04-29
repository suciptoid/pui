import Popover from "./popover";
import DatePicker from "./date_picker";
import Select from "./select";
import LoadingBar from "./loading";
import Tooltip from "./tooltip";
import FlashGroup from "./flash";
import Tabs from "./tabs";
import Sidebar from "./sidebar";

export const Hooks = {
  "PUI.LoadingBar": LoadingBar,
  "PUI.Popover": Popover,
  "PUI.DatePicker": DatePicker,
  "PUI.Select": Select,
  "PUI.Tabs": Tabs,
  "PUI.Tooltip": Tooltip,
  "PUI.FlashGroup": FlashGroup,
  "PUI.Sidebar": Sidebar,
};

export { Popover, DatePicker, Select, LoadingBar, Tabs, Tooltip, FlashGroup, Sidebar };
