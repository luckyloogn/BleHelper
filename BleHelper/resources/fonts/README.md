# BleHelperIcons.ttf

自定义图标，利用svg文件和 [glyphter](https://glyphter.com/) 网站制作，用于FluIcon，修改font.family属性：

```qml
FontLoader {
    id: font_loader
    source: "qrc:/resources/fonts/BleHelperIcons.ttf"
}

FluIcon {
    font.family: font_loader.name
    iconSize: 12
    iconSource: 65 // 从A (65)开始: 65 ---> Scan, 66 --->Details ...
}
```