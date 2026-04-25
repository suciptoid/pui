import Popover from "./popover";
import Select from "./select";
import LoadingBar from "./loading";
import Tooltip from "./tooltip";
import FlashGroup from "./flash";
import Tabs from "./tabs";
import SidebarMenuItemCollapse from "./sidebar_menu_item_collapse";

export const Hooks = {
  "PUI.LoadingBar": LoadingBar,
  "PUI.Popover": Popover,
  "PUI.Select": Select,
  "PUI.Tabs": Tabs,
  "PUI.Tooltip": Tooltip,
  "PUI.FlashGroup": FlashGroup,
  "PUI.SidebarMenuItemCollapse": SidebarMenuItemCollapse,
};

export { Popover, Select, LoadingBar, Tabs, Tooltip, FlashGroup, SidebarMenuItemCollapse };
