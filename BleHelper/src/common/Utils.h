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
    static QString byteArrayToHex(const QByteArray &value, char separator = ' ', bool upper = true);
    static QString byteArrayToAscii(const QByteArray &value);
    static QString byteArrayToDecimal(const QByteArray &value, char separator = ' ');
    static QString parseDescriptorValue(const QByteArray &value,
                                        QBluetoothUuid::DescriptorType type);
};
