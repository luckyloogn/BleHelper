#pragma once

#include <QLowEnergyCharacteristic>
#include <QObject>
#include <QString>

#include "stdafx.h"

class CharacteristicInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY_READONLY_AUTO(QString, name)
    Q_PROPERTY_READONLY_AUTO(QString, uuid)
    Q_PROPERTY_READONLY_AUTO(QString, properties)
    Q_PROPERTY_READONLY_AUTO(bool, canIndicate)
    Q_PROPERTY_READONLY_AUTO(bool, canNotify)
    Q_PROPERTY_READONLY_AUTO(bool, canRead)
    Q_PROPERTY_READONLY_AUTO(bool, canWrite)
    Q_PROPERTY_READONLY_AUTO(bool, canWriteNoResponse)
    Q_PROPERTY_READONLY_AUTO(bool, canRename)
    Q_PROPERTY_READONLY_AUTO(QString, valueHex)
    Q_PROPERTY_READONLY_AUTO(QString, valueAscii)
    Q_PROPERTY_READONLY_AUTO(QString, valueDecimal)
    Q_PROPERTY_READONLY_AUTO(bool, enableIndications)
    Q_PROPERTY_READONLY_AUTO(bool, enableNotifications)

public:
    CharacteristicInfo() = default;
    CharacteristicInfo(const QLowEnergyCharacteristic &c);

    const QLowEnergyCharacteristic &characteristic() const;

private:
    QLowEnergyCharacteristic _characteristic;
};
