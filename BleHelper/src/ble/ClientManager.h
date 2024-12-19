#pragma once

#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothLocalDevice>
#include <QHash>
#include <QList>
#include <QLowEnergyController>
#include <QMap>
#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QVariant>
#include <QVariantList>

#include "BaseClass.h"
#include "CharacteristicInfo.h"
#include "DescriptorInfo.h"
#include "DeviceInfo.h"
#include "FilterParams.h"
#include "ServiceInfo.h"
#include "SettingsManager.h"
#include "singleton.h"
#include "stdafx.h"

class ClientManager : public BaseClass
{
    Q_OBJECT

    Q_PROPERTY_AUTO(int, scanTimeout)
    Q_PROPERTY_AUTO_P(FilterParams *, filterParams)
    Q_PROPERTY_READONLY_AUTO(bool, isDeviceConnected)
    Q_PROPERTY_AUTO_P(DeviceInfo *, connectedDeviceInfo)
    Q_PROPERTY_AUTO(bool, isUuidNameMappingEnabled)

    Q_PROPERTY(bool isBluetoothOn READ isBluetoothOn NOTIFY isBluetoothOnChanged)
    Q_PROPERTY(bool isScanning READ isScanning NOTIFY isScanningChanged)
    Q_PROPERTY(QVariant filteredDevices READ filteredDevices NOTIFY filteredDevicesChanged)
    Q_PROPERTY(QVariantList favoriteDevices READ favoriteDevices NOTIFY favoriteDevicesChanged)

    Q_PROPERTY(QVariant services READ services NOTIFY servicesChanged)
    Q_PROPERTY(QVariantMap characteristics READ characteristics NOTIFY characteristicsChanged)
    Q_PROPERTY(QVariantMap descriptors READ descriptors NOTIFY descriptorsChanged)

    Q_PROPERTY(QVariantList serviceUuidDictionary READ serviceUuidDictionary NOTIFY
                       serviceUuidDictionaryChanged)
    Q_PROPERTY(QVariantList characteristicUuidDictionary READ characteristicUuidDictionary NOTIFY
                       characteristicUuidDictionaryChanged)

public:
    enum Error {
        NoError,
        PoweredOffError,
        PairingError,
        MissingPermissionsError,
        ConnectionError,
        RemoteHostClosedError,
        OperationError,
        CharacteristicReadError,
        CharacteristicWriteError,
        DescriptorReadError,
        DescriptorWriteError,
        UnknownError
    };
    Q_ENUM(Error)
    enum AttributeType { Unknown = 0x00, Service = 0x01, Characteristic = 0x02, Descriptor = 0x04 };
    Q_ENUM(AttributeType)

    SINGLETON(ClientManager);
    ~ClientManager() override;

    Q_INVOKABLE void enableBluetooth();
    Q_INVOKABLE void disableBluetooth();
    Q_INVOKABLE void startScan();
    Q_INVOKABLE void stopScan();
    Q_INVOKABLE void pairWithDevice(const QString &address);
    Q_INVOKABLE void unpairWithDevice(const QString &address);
    Q_INVOKABLE void sortByRssi(bool descending = true);
    Q_INVOKABLE void insertDeviceToFavorites(const QString &address, const QString &name);
    Q_INVOKABLE void deleteDeviceFromFavorites(const QString &address);
    Q_INVOKABLE void deleteAllDevicesFromFavorites();
    Q_INVOKABLE void updateFilteredDevices();
    Q_INVOKABLE void connectToDevice(const QString &address);
    Q_INVOKABLE void disconnectFromDevice();
    Q_INVOKABLE void renameAttribute(ServiceInfo *srvInfo, const QString &newName);
    Q_INVOKABLE void renameAttribute(CharacteristicInfo *charInfo, const QString &newName);
    Q_INVOKABLE void refreshAttributeName(const QString &uuid, AttributeType type);
    Q_INVOKABLE void upsertAttributeToUuidDictionary(const QString &uuid, const QString &name,
                                                     AttributeType type);
    Q_INVOKABLE void deleteAttributeFromUuidDictionary(const QString &uuid, AttributeType type);
    Q_INVOKABLE void deleteAllAttributesFromUuidDictionary(AttributeType type);
    Q_INVOKABLE bool importUuidDictionary(const QString &fileName);
    Q_INVOKABLE bool exportUuidDictionary(const QString &fileName);

    bool isBluetoothOn() const;
    bool isScanning() const;
    QVariant filteredDevices() const;
    QVariantList favoriteDevices() const;

    QVariant services() const;
    QVariantMap characteristics() const;
    QVariantMap descriptors() const;

    QVariantList serviceUuidDictionary() const;
    QVariantList characteristicUuidDictionary() const;

public slots:
    Q_INVOKABLE void refreshAllAttributesName();

signals:
    void errorOccurred(Error error);
    void isBluetoothOnChanged();
    void isScanningChanged();
    void filteredDevicesChanged();
    void favoriteDevicesChanged();
    void requestPairingSucceeded(const DeviceInfo *devInfo);

    void servicesChanged();
    void characteristicsChanged();
    void descriptorsChanged();

    void serviceUuidDictionaryChanged();
    void characteristicUuidDictionaryChanged();

private:
    explicit ClientManager(QObject *parent = nullptr);

    void initializeVariables();

    void loadFavouriteDevices();
    void loadUuidDictionary();

    void initLocalDevice();
    void initDeviceDiscoveryAgent();
    void addDeviceToFiltered(DeviceInfo *device);
    void clearAllDevices();
    void clearAllAttributes(bool emitChangedSignals);

private slots:
    /* QBluetoothLocalDevice */
    void localDeviceError(QBluetoothLocalDevice::Error error);
    void hostModeChanged(QBluetoothLocalDevice::HostMode mode);
    void pairingFinished(const QBluetoothAddress &address, QBluetoothLocalDevice::Pairing pairing);

    /* QBluetoothDeviceDiscoveryAgent */
    void discoveryAgentError(QBluetoothDeviceDiscoveryAgent::Error error);
    void addDevice(const QBluetoothDeviceInfo &info);
    void updateDevice(const QBluetoothDeviceInfo &info, QBluetoothDeviceInfo::Fields updatedFields);
    void deviceScanFinished();
    void updateScanTimeout();

    /* QLowEnergyController */
    void controllerError(QLowEnergyController::Error error);
    void controllerConnected();
    void controllerDisconnected();
    void addService(const QBluetoothUuid &serviceUuid);
    void serviceScanFinished();

    /* QLowEnergyService */
    void serviceError(QLowEnergyService::ServiceError error);
    void serviceStateChanged(QLowEnergyService::ServiceState state);
    void characteristicChanged(const QLowEnergyCharacteristic &characteristic,
                               const QByteArray &value);
    void characteristicRead(const QLowEnergyCharacteristic &characteristic,
                            const QByteArray &value);
    void characteristicWritten(const QLowEnergyCharacteristic &characteristic,
                               const QByteArray &value);
    void descriptorRead(const QLowEnergyDescriptor &descriptor, const QByteArray &value);
    void descriptorWritten(const QLowEnergyDescriptor &descriptor, const QByteArray &value);

private:
    SettingsManager *_settingsManager = SettingsManager::getInstance();

    QBluetoothLocalDevice *_localDevice = nullptr;
    QBluetoothDeviceDiscoveryAgent *_deviceDiscoveryAgent = nullptr;

    QHash<QString, DeviceInfo *> _allDevices; // {deviceAddress, DeviceInfo *}
    QList<DeviceInfo *> _filteredDevices;
    QHash<QString, QString> _favoriteDevices; // {deviceAddress, deviceName}

    QLowEnergyController *_lowEnergyController = nullptr;
    DeviceInfo *_currentSelectedDeviceInfo = nullptr;
    QMap<QString, ServiceInfo *> _allServices; // {srvUuid, ServiceInfo *}
    QHash<QString, QMap<QString, CharacteristicInfo *>>
            _allCharacteristics; // {srvUuid, {charUuid, CharacteristicInfo *}}
    QHash<QString, QMap<QString, DescriptorInfo *>>
            _allDescriptors; // {charUuid, {descUuid, DescriptorInfo *}}

    QHash<QString, QString> _serviceUuidDictionary; // {uuid, name}
    QHash<QString, QString> _characteristicUuidDictionary; // {uuid, name}
};
