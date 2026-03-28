# Quickshell

After making changes, format and lint all QML files:

```sh
find ~/.config/quickshell -name '*.qml' -exec qmlformat -i {} +
find ~/.config/quickshell -name '*.qml' -exec qmllint {} +
```
