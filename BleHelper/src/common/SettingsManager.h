#pragma once

#include <QColor>
#include <QHash>
#include <QObject>
#include <QQmlEngine>
#include <QSettings>
#include <QTranslator>

#include "singleton.h"
#include "stdafx.h"

class SettingsManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY_READONLY_AUTO(QVariantList, supportedLanguages)

public:
    SINGLETON(SettingsManager);
    ~SettingsManager() override;

    /* Window Size */
    Q_INVOKABLE bool isWindowMaximized();
    Q_INVOKABLE void saveWindowMaximized(bool maximized);
    Q_INVOKABLE int windowWidth();
    Q_INVOKABLE void saveWindowWidth(int width);
    Q_INVOKABLE int windowHeight();
    Q_INVOKABLE void saveWindowHeight(int height);

    /* Appearance */
    Q_INVOKABLE int darkMode();
    Q_INVOKABLE void saveDarkMode(int darkModel);
    Q_INVOKABLE int navigationViewType();
    Q_INVOKABLE void saveNavigationViewType(int type);
    Q_INVOKABLE QColor accentNormalColor();
    Q_INVOKABLE void saveAccentNormalColor(QColor primaryColor);
    Q_INVOKABLE bool isAnimationEnabled();
    Q_INVOKABLE void saveAnimationEnabled(bool enable);
    Q_INVOKABLE bool isBlurBehindWindowEnabled();
    Q_INVOKABLE void saveBlurBehindWindowEnabled(bool enable);
    Q_INVOKABLE bool isNativeTextEnabled();
    Q_INVOKABLE void saveNativeTextEnabled(bool enable);

    /* Localization */
    Q_INVOKABLE QString language();
    Q_INVOKABLE void saveLanguage(const QString &language);
    void initTranslator(QQmlEngine *engine);

private:
    explicit SettingsManager(QObject *parent = nullptr);

    void createLanguagesMap();
    void updateSupportedLanguages();
    QString getCurrentLanguageResourcePath();

    QQmlEngine *_engine = nullptr;
    QSettings *_settings = nullptr;
    QTranslator *_translator = nullptr;
    QString _currentLanguage;
    QString _translationsResourcePath;
    QHash<QString, QString> _languageMap; // {language code, language name}
};
