#pragma once

#include <QLowEnergyService>
#include <QObject>

#include "stdafx.h"

class ServiceInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY_READONLY_AUTO(QString, name)
    Q_PROPERTY_READONLY_AUTO(QString, uuid)
    Q_PROPERTY_READONLY_AUTO(QString, type)
    Q_PROPERTY_READONLY_AUTO(bool, canRename)

public:
    ServiceInfo() = default;
    ServiceInfo(QLowEnergyService *s);

    QLowEnergyService *getQLowEnergyService() const;

private:
    QLowEnergyService *_service = nullptr;
};
