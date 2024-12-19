#pragma once

#include <QBluetoothUuid>
#include <QLowEnergyCharacteristic>
#include <QLowEnergyDescriptor>
#include <QLowEnergyService>
#include <QString>

class Utils
{
public:
    static QString uuidToString(const QBluetoothUuid &uuid);
    static QString getAttributeName(const QLowEnergyService *s, bool *canRename = nullptr);
    static QString getAttributeName(const QLowEnergyCharacteristic &c, bool *canRename = nullptr);
    static QString getAttributeName(const QLowEnergyDescriptor &d, bool *canRename = nullptr);
};
