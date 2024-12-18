#pragma once

#include <QObject>

#include "singleton.h"
#include "stdafx.h"

class ApplicationInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY_READONLY_AUTO(QString, applicationName)
    Q_PROPERTY_READONLY_AUTO(QString, versionName)
    Q_PROPERTY_READONLY_AUTO(QString, buildDateTime)
    Q_PROPERTY_READONLY_AUTO(QString, author)
    Q_PROPERTY_READONLY_AUTO(QString, repositoryUrl)
    Q_PROPERTY_READONLY_AUTO(QString, updateCheckUrl)
    Q_PROPERTY_READONLY_AUTO(QString, updateUrl)

public:
    SINGLETON(ApplicationInfo);
    ~ApplicationInfo() override;

private:
    explicit ApplicationInfo(QObject *parent = nullptr);
};
