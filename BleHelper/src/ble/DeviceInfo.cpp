#include <QBluetoothAddress>
#include <QBluetoothUuid>

#include "DeviceInfo.h"

DeviceInfo::DeviceInfo(const QBluetoothDeviceInfo &info)
{
    update(info);

    /* isFavorite */
    isFavorite(false);

    /* isConnected */
    isConnected(false);

    /* isPaired */
    isPaired(false);
}

void DeviceInfo::update(const QBluetoothDeviceInfo &info)
{
    _qBluetoothDeviceInfo = info;

    /* name */
    name(info.name());

    /* address */
    address(info.address().toString());

    /* rssi */
    rssi(info.rssi());
}

QBluetoothDeviceInfo DeviceInfo::getQBluetoothDeviceInfo() const
{
    return _qBluetoothDeviceInfo;
}
