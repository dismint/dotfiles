import { WindowNotification } from "./notification.js";

const scss = `${App.configDir}/style.scss`;
const css = "/tmp/style.css";

Utils.exec(`sassc ${scss} ${css}`);

App.config({
  style: css,
  windows: [WindowNotification()],
});
