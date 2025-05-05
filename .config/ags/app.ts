import { App } from "astal/gtk3";
import NotificationManager from "./notifications/NotificationManager";
import { exec } from "astal";

const scss = "./style.scss";
const css = "/tmp/style.css";
exec(`sassc ${scss} ${css}`);

App.start({
  instanceName: "notifications",
  css: css,
  main: () => NotificationManager(App.get_monitors()[2]),
});
