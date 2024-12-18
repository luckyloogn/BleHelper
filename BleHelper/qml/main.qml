import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import BleHelper
import FluentUI

FluLauncher {
    id: main

    Component.onCompleted: {
        FluApp.init(main, Qt.locale(SettingsManager.language()));
        FluApp.windowIcon = "qrc:/resources/images/icons/logo_32x32.png";
        FluApp.useSystemAppBar = false;
        FluTheme.darkMode = SettingsManager.darkMode();
        FluTheme.accentColor = GlobalModel.createAccentColor(SettingsManager.accentNormalColor());
        FluTheme.animationEnabled = SettingsManager.isAnimationEnabled();
        FluTheme.blurBehindWindowEnabled = SettingsManager.isBlurBehindWindowEnabled();
        FluTheme.nativeText = SettingsManager.isNativeTextEnabled();
        FluRouter.routes = {
            "/": "qrc:/qml/windows/MainWindow.qml",
            "/crash": "qrc:/qml/windows/CrashWindow.qml"
        };
        var args = Qt.application.arguments;
        if (args.length >= 2 && args[1].startsWith("-crashed=")) {
            FluRouter.navigate("/crash");
        } else {
            FluRouter.navigate("/");
        }
    }
}
