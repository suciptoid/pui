import Popover from "./popover";
import DatePicker from "./date_picker";
import Select from "./select";
import LoadingBar from "./loading";
import Tooltip from "./tooltip";
import FlashGroup from "./flash";
import Tabs from "./tabs";
import Sidebar from "./sidebar";
import ChartHook from "./chart_hook";
import BarChart from "./bar_chart";
import LineChart from "./line_chart";
import SparklineChart from "./sparkline_chart";

export const Hooks = {
  "PUI.LoadingBar": LoadingBar,
  "PUI.Popover": Popover,
  "PUI.DatePicker": DatePicker,
  "PUI.Select": Select,
  "PUI.Tabs": Tabs,
  "PUI.Tooltip": Tooltip,
  "PUI.FlashGroup": FlashGroup,
  "PUI.Sidebar": Sidebar,
  "PUI.Chart": ChartHook,
  "PUI.BarChart": BarChart,
  "PUI.LineChart": LineChart,
  "PUI.SparklineChart": SparklineChart,
};

export {
  Popover,
  DatePicker,
  Select,
  LoadingBar,
  Tabs,
  Tooltip,
  FlashGroup,
  Sidebar,
  ChartHook,
  BarChart,
  LineChart,
  SparklineChart,
};
