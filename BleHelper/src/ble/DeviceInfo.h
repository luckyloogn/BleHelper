#pragma once

#include <QBluetoothDeviceInfo>
#include <QObject>
#include <QString>

#include "stdafx.h"

class DeviceInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY_READONLY_AUTO(QString, name)
    Q_PROPERTY_READONLY_AUTO(QString, address)
    Q_PROPERTY_READONLY_AUTO(int, rssi)
    Q_PROPERTY_READONLY_AUTO(bool, isFavorite)
    Q_PROPERTY_READONLY_AUTO(bool, isConnected)
    Q_PROPERTY_READONLY_AUTO(bool, isPaired)

public:
    DeviceInfo() = default;
    DeviceInfo(const QBluetoothDeviceInfo &info);

    void update(const QBluetoothDeviceInfo &info);
    QBluetoothDeviceInfo getQBluetoothDeviceInfo() const;

private:
    QBluetoothDeviceInfo _qBluetoothDeviceInfo;
};
