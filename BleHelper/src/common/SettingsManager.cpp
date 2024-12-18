#include <QDir>
#include <QGuiApplication>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>
#include <QStringLiteral>

#include "BuildConfig.h"
#include "SettingsManager.h"

SettingsManager::SettingsManager(QObject *parent) : QObject(parent)
{
    auto appDataLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QString iniFileName = QStringLiteral("%1/%2.ini").arg(appDataLocation, APPLICATION_NAME);
    _settings = new QSettings(iniFileName, QSettings::IniFormat, this);
}

SettingsManager::~SettingsManager() = default;

/* Window Size */
bool SettingsManager::isWindowMaximized()
{
    return _settings->value("isWindowMaximized", QVariant(false)).toBool();
}

void SettingsManager::saveWindowMaximized(bool maximized)
{
    _settings->setValue("isWindowMaximized", maximized);
}

int SettingsManager::windowWidth()
{
    return _settings->value("windowWidth", QVariant(1024)).toInt();
}

void SettingsManager::saveWindowWidth(int width)
{
    _settings->setValue("windowWidth", width);
}

int SettingsManager::windowHeight()
{
    return _settings->value("windowHeight", QVariant(768)).toInt();
}

void SettingsManager::saveWindowHeight(int height)
{
    _settings->setValue("windowHeight", height);
}

/* Appearance */
int SettingsManager::darkMode()
{
    return _settings->value("darkMode", QVariant(0)).toInt();
}

void SettingsManager::saveDarkMode(int darkModel)
{
    _settings->setValue("darkMode", darkModel);
}

int SettingsManager::navigationViewType()
{
    // 0x0004: Auto
    return _settings->value("navigationViewType", QVariant(0x0004)).toInt();
}

void SettingsManager::saveNavigationViewType(int type)
{
    _settings->setValue("navigationViewType", type);
}

QColor SettingsManager::accentNormalColor()
{
    return QColor(_settings->value("accentNormalColor", QVariant("#0078D4")).toString());
}

void SettingsManager::saveAccentNormalColor(QColor primaryColor)
{
    _settings->setValue("accentNormalColor", primaryColor);
}

bool SettingsManager::isAnimationEnabled()
{
    return _settings->value("isAnimationEnabled", QVariant(true)).toBool();
}

void SettingsManager::saveAnimationEnabled(bool enable)
{
    _settings->setValue("isAnimationEnabled", enable);
}

bool SettingsManager::isBlurBehindWindowEnabled()
{
    return _settings->value("isBlurBehindWindowEnabled", QVariant(false)).toBool();
}

void SettingsManager::saveBlurBehindWindowEnabled(bool enable)
{
    _settings->setValue("isBlurBehindWindowEnabled", enable);
}

bool SettingsManager::isNativeTextEnabled()
{
    return _settings->value("isNativeTextEnabled", QVariant(false)).toBool();
}

void SettingsManager::saveNativeTextEnabled(bool enable)
{
    _settings->setValue("isNativeTextEnabled", enable);
}

/* Localization */
QString SettingsManager::language()
{
    return _settings->value("language", QVariant("en_US")).toString();
}

void SettingsManager::saveLanguage(const QString &language)
{
    _settings->setValue("language", language);
    _currentLanguage = language;

    if (_translator->load(getCurrentLanguageResourcePath())) {
        _engine->retranslate();
    }
}

void SettingsManager::initTranslator(QQmlEngine *engine)
{
    _engine = engine;
    _currentLanguage = language();
    _translationsResourcePath = QGuiApplication::applicationDirPath() + "/i18n";

    createLanguagesMap();
    updateSupportedLanguages();

    _translator = new QTranslator(this);
    QGuiApplication::installTranslator(_translator);
    if (_translator->load(getCurrentLanguageResourcePath())) {
        _engine->retranslate();
    }
}

void SettingsManager::createLanguagesMap()
{
    _languageMap.clear();

    QString filePath = QGuiApplication::applicationDirPath() + "/i18n/languages.json";
    QFile file(filePath);

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Failed to open languages.json:" << file.errorString();
        return;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument jsonDoc = QJsonDocument::fromJson(data);
    if (!jsonDoc.isObject()) {
        qWarning() << "Invalid JSON format in languages.json";
        return;
    }

    QJsonObject jsonObj = jsonDoc.object();
    for (auto it = jsonObj.begin(); it != jsonObj.end(); ++it) {
        _languageMap.insert(it.key(), it.value().toString());
    }
}

void SettingsManager::updateSupportedLanguages()
{
    QDir dir(_translationsResourcePath);

    dir.setNameFilters(QStringList() << "*.qm");

    QStringList qmFiles = dir.entryList(QDir::Files);

    QVariantList list;
    for (const QString &fileName : qmFiles) {
        QString code = fileName.left(fileName.lastIndexOf('.')); // Remove file extension
        QVariantMap item;
        item.insert("code", code);
        item.insert("name", _languageMap.value(code, "Unknown Language"));
        list.append(item);
    }
    supportedLanguages(list);
}

QString SettingsManager::getCurrentLanguageResourcePath()
{
    QString fileName = QStringLiteral("%1/%2.qm").arg(_translationsResourcePath, _currentLanguage);
    return fileName;
}