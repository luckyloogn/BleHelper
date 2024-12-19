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

    /* Bluetooth */
    Q_INVOKABLE int scanTimeout();
    Q_INVOKABLE void saveScanTimeout(int timeout);
    Q_INVOKABLE bool isUuidNameMappingEnabled();
    Q_INVOKABLE void saveUuidNameMappingEnabled(bool enable);

    const QHash<QString, QString> favoriteDevices();
    void saveFavoriteDevices(const QHash<QString, QString> &devices);
    const QHash<QString, QString> serviceUuidDictionary();
    void saveServiceUuidDictionary(const QHash<QString, QString> &uuidDictionary);
    const QHash<QString, QString> characteristicUuidDictionary();
    void saveCharacteristicUuidDictionary(const QHash<QString, QString> &uuidDictionary);

private:
    explicit SettingsManager(QObject *parent = nullptr);

    const QHash<QString, QString> loadHash(const QString &key);
    void saveHash(const QString &key, const QHash<QString, QString> &hash);

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
