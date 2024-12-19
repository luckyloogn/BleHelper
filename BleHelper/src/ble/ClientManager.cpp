#include <QFile>
#include <QHash>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>

#include "ClientManager.h"
#include "Utils.h"

ClientManager::ClientManager(QObject *parent) : BaseClass(parent)
{
    initializeVariables();

    loadFavouriteDevices();
    loadUuidDictionary();

    initLocalDevice();
    initDeviceDiscoveryAgent();
}

ClientManager::~ClientManager()
{
    clearAllDevices();
    _filteredDevices.clear();

    clearAllAttributes(false);
}

void ClientManager::enableBluetooth()
{
    if (_localDevice && _localDevice->isValid()
        && _localDevice->hostMode() == QBluetoothLocalDevice::HostPoweredOff) {
        _localDevice->powerOn();
    }
}

void ClientManager::disableBluetooth()
{
    if (isScanning()) {
        stopScan();
    }

    if (_localDevice && _localDevice->isValid()
        && _localDevice->hostMode() != QBluetoothLocalDevice::HostPoweredOff) {
        _localDevice->setHostMode(QBluetoothLocalDevice::HostPoweredOff);
    }
}

void ClientManager::startScan()
{
    if (_deviceDiscoveryAgent) {
        clearAllDevices();

        updateFilteredDevices();

        _deviceDiscoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);

        emit isScanningChanged();

        showInfo("Scanning for devices...");
    }
}

void ClientManager::stopScan()
{
    if (isScanning()) {
        _deviceDiscoveryAgent->stop();

        emit isScanningChanged();
    }
}

void ClientManager::pairWithDevice(const QString &address)
{
    if (_localDevice && _localDevice->isValid()
        && _localDevice->hostMode() != QBluetoothLocalDevice::HostPoweredOff
        && _allDevices.contains(address)) {
        auto devInfo = _allDevices[address];
        auto addr = devInfo->getQBluetoothDeviceInfo().address();

        QTimer::singleShot(0, this, [=]() {
            _localDevice->requestPairing(addr, QBluetoothLocalDevice::AuthorizedPaired);
        });
    }
}

void ClientManager::unpairWithDevice(const QString &address)
{
    if (_localDevice && _localDevice->isValid()
        && _localDevice->hostMode() != QBluetoothLocalDevice::HostPoweredOff
        && _allDevices.contains(address)) {
        auto devInfo = _allDevices[address];
        auto addr = devInfo->getQBluetoothDeviceInfo().address();

        QTimer::singleShot(0, this, [=]() {
            _localDevice->requestPairing(addr, QBluetoothLocalDevice::Unpaired);
            ;
        });
    }
}

void ClientManager::sortByRssi(bool descending)
{
    std::sort(_filteredDevices.begin(), _filteredDevices.end(),
              [descending](DeviceInfo *a, DeviceInfo *b) {
                  if (descending) {
                      return a->rssi() > b->rssi();
                  }
                  return a->rssi() < b->rssi();
              });

    emit filteredDevicesChanged();
}

void ClientManager::insertDeviceToFavorites(const QString &address, const QString &name)
{
    if (!_favoriteDevices.contains(address)) {
        _favoriteDevices.insert(address, name);
        if (_allDevices.contains(address)) {
            _allDevices[address]->isFavorite(true);
        }
        emit favoriteDevicesChanged();

        _settingsManager->saveFavoriteDevices(_favoriteDevices);
    }
}

void ClientManager::deleteDeviceFromFavorites(const QString &address)
{
    if (_favoriteDevices.contains(address)) {
        _favoriteDevices.remove(address);
        if (_allDevices.contains(address)) {
            _allDevices[address]->isFavorite(false);
        }
        emit favoriteDevicesChanged();

        _settingsManager->saveFavoriteDevices(_favoriteDevices);
    }
}

void ClientManager::deleteAllDevicesFromFavorites()
{
    for (auto it = _favoriteDevices.begin(); it != _favoriteDevices.end(); ++it) {
        auto address = it.key();
        if (_allDevices.contains(address)) {
            _allDevices[address]->isFavorite(false);
        }
    }

    _favoriteDevices.clear();
    emit favoriteDevicesChanged();

    _settingsManager->saveFavoriteDevices(_favoriteDevices);
}

void ClientManager::updateFilteredDevices()
{
    _filteredDevices.clear();

    for (auto it = _allDevices.begin(); it != _allDevices.end(); ++it) {
        addDeviceToFiltered(it.value());
    }

    emit filteredDevicesChanged();
}

void ClientManager::connectToDevice(const QString &address)
{
    if (!_allDevices.contains(address)) {
        showError("Can not find device: %s", address.toStdString().c_str());
        return;
    }

    DeviceInfo *devInfo = _allDevices[address];
    if (!devInfo->getQBluetoothDeviceInfo().isValid()) {
        showError("Not a valid device");
        return;
    }

    if (_connectedDeviceInfo && _connectedDeviceInfo->isConnected()
        && _connectedDeviceInfo->address() == address) {
        showInfo("%s has connected", address.toStdString().c_str());
        return;
    }

    if (_lowEnergyController) {
        _lowEnergyController->disconnectFromDevice();
        delete _lowEnergyController;
        _lowEnergyController = nullptr;
    }

    showInfo("Connecting to device...");

    _currentSelectedDeviceInfo = devInfo;
    _lowEnergyController =
            QLowEnergyController::createCentral(devInfo->getQBluetoothDeviceInfo(), this);

    connect(_lowEnergyController, &QLowEnergyController::errorOccurred, this,
            &ClientManager::controllerError);
    connect(_lowEnergyController, &QLowEnergyController::connected, this,
            &ClientManager::controllerConnected);
    connect(_lowEnergyController, &QLowEnergyController::disconnected, this,
            &ClientManager::controllerDisconnected);
    connect(_lowEnergyController, &QLowEnergyController::serviceDiscovered, this,
            &ClientManager::addService);
    connect(_lowEnergyController, &QLowEnergyController::discoveryFinished, this,
            &ClientManager::serviceScanFinished);

    _lowEnergyController->setRemoteAddressType(QLowEnergyController::PublicAddress);
    _lowEnergyController->connectToDevice();
}

void ClientManager::disconnectFromDevice()
{
    if (_lowEnergyController) {
        showInfo("Disconnect from device");

        _lowEnergyController->disconnectFromDevice();
    }
}

void ClientManager::renameAttribute(ServiceInfo *srvInfo, const QString &newName)
{
    if (srvInfo) {
        upsertAttributeToUuidDictionary(srvInfo->uuid(), newName, AttributeType::Service);
        srvInfo->name(newName);
    }
}

void ClientManager::renameAttribute(CharacteristicInfo *charInfo, const QString &newName)
{
    if (charInfo) {
        upsertAttributeToUuidDictionary(charInfo->uuid(), newName, AttributeType::Characteristic);
        charInfo->name(newName);
    }
}

void ClientManager::refreshAttributeName(const QString &uuid, AttributeType type)
{
    if (!_isDeviceConnected) {
        return;
    }

    QString newName;

    if (AttributeType::Service == type && _allServices.contains(uuid)) {
        ServiceInfo *srvInfo = _allServices[uuid];
        if (_isUuidNameMappingEnabled && _serviceUuidDictionary.contains(uuid)) {
            newName = _serviceUuidDictionary[uuid];
        } else {
            newName = Utils::getAttributeName(srvInfo->service());
        }
        srvInfo->name(newName);
    } else if (AttributeType::Characteristic == type) {
        for (auto it = _allServices.begin(); it != _allServices.end(); ++it) {
            QString srvUuid = it.key();

            QMap<QString, CharacteristicInfo *> charInfos = _allCharacteristics[srvUuid];
            if (charInfos.contains(uuid)) {
                CharacteristicInfo *charInfo = charInfos[uuid];
                if (_isUuidNameMappingEnabled && _characteristicUuidDictionary.contains(uuid)) {
                    newName = _characteristicUuidDictionary[uuid];
                } else {
                    newName = Utils::getAttributeName(charInfo->characteristic());
                }
                charInfo->name(newName);
                break;
            }
        }
    }
}

void ClientManager::upsertAttributeToUuidDictionary(const QString &uuid, const QString &name,
                                                    AttributeType type)
{
    if (AttributeType::Service == type) {
        _serviceUuidDictionary[uuid] = name;
        emit serviceUuidDictionaryChanged();

        _settingsManager->saveServiceUuidDictionary(_serviceUuidDictionary);
    } else if (AttributeType::Characteristic == type) {
        _characteristicUuidDictionary[uuid] = name;
        emit characteristicUuidDictionaryChanged();

        _settingsManager->saveCharacteristicUuidDictionary(_characteristicUuidDictionary);
    }
}

void ClientManager::deleteAttributeFromUuidDictionary(const QString &uuid, AttributeType type)
{
    if (AttributeType::Service == type && _serviceUuidDictionary.contains(uuid)) {
        _serviceUuidDictionary.remove(uuid);
        emit serviceUuidDictionaryChanged();

        _settingsManager->saveServiceUuidDictionary(_serviceUuidDictionary);
    } else if (AttributeType::Characteristic == type
               && _characteristicUuidDictionary.contains(uuid)) {
        _characteristicUuidDictionary.remove(uuid);
        emit characteristicUuidDictionaryChanged();

        _settingsManager->saveCharacteristicUuidDictionary(_characteristicUuidDictionary);
    }
}

void ClientManager::deleteAllAttributesFromUuidDictionary(AttributeType type)
{
    if (AttributeType::Service & type) {
        _serviceUuidDictionary.clear();
        emit serviceUuidDictionaryChanged();

        _settingsManager->saveServiceUuidDictionary(_serviceUuidDictionary);
    }

    if (AttributeType::Characteristic & type) {
        _characteristicUuidDictionary.clear();
        emit characteristicUuidDictionaryChanged();

        _settingsManager->saveCharacteristicUuidDictionary(_characteristicUuidDictionary);
    }
}

bool ClientManager::importUuidDictionary(const QString &fileName)
{
    QFile file(fileName);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        showWarning("Failed to open file for reading: %s", fileName.toStdString().c_str());
        return false;
    }

    QByteArray fileData = file.readAll();
    file.close();

    QJsonDocument jsonDoc = QJsonDocument::fromJson(fileData);
    if (jsonDoc.isNull() || !jsonDoc.isArray()) {
        showWarning("Invalid JSON format or not an array");
        return false;
    }

    QJsonArray jsonArray = jsonDoc.array();
    for (const QJsonValue &value : jsonArray) {
        if (value.isObject()) {
            QJsonObject jsonObject = value.toObject();

            QString uuid = jsonObject["uuid"].toString().toUpper();
            QString name = jsonObject["name"].toString();
            int type = jsonObject["type"].toInt();

            if (type == AttributeType::Service) {
                _serviceUuidDictionary[uuid] = name;
            } else if (type == AttributeType::Characteristic) {
                _characteristicUuidDictionary[uuid] = name;
            } else {
                showWarning("Unknown attribute type %d for UUID %s", type,
                            uuid.toStdString().c_str());
            }
        }
    }

    emit serviceUuidDictionaryChanged();
    emit characteristicUuidDictionaryChanged();

    _settingsManager->saveServiceUuidDictionary(_serviceUuidDictionary);
    _settingsManager->saveCharacteristicUuidDictionary(_characteristicUuidDictionary);

    showInfo("Successfully imported the UUID dictionary from JSON file: %s",
             fileName.toStdString().c_str());

    return true;
}

bool ClientManager::exportUuidDictionary(const QString &fileName)
{
    QJsonArray jsonArray;

    for (auto it = _serviceUuidDictionary.begin(); it != _serviceUuidDictionary.end(); ++it) {
        QJsonObject jsonObject;
        jsonObject["uuid"] = it.key().toUpper();
        jsonObject["name"] = it.value();
        jsonObject["type"] = AttributeType::Service;
        jsonArray.append(jsonObject);
    }

    for (auto it = _characteristicUuidDictionary.begin(); it != _characteristicUuidDictionary.end();
         ++it) {
        QJsonObject jsonObject;
        jsonObject["uuid"] = it.key().toUpper();
        jsonObject["name"] = it.value();
        jsonObject["type"] = AttributeType::Characteristic;
        jsonArray.append(jsonObject);
    }

    QJsonDocument jsonDocument(jsonArray);

    QFile file(fileName);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        showWarning("Failed to open file for writing: %s", fileName.toStdString().c_str());
        return false;
    }

    file.write(jsonDocument.toJson(QJsonDocument::Indented));
    file.close();

    showInfo("Successfully exported the UUID dictionary: %s", fileName.toStdString().c_str());

    return true;
}

bool ClientManager::isBluetoothOn() const
{
    return _localDevice && _localDevice->isValid()
            && _localDevice->hostMode() != QBluetoothLocalDevice::HostPoweredOff;
}

bool ClientManager::isScanning() const
{
    return _deviceDiscoveryAgent && _deviceDiscoveryAgent->isActive();
}

QVariant ClientManager::filteredDevices() const
{
    return QVariant::fromValue(_filteredDevices);
}

QVariantList ClientManager::favoriteDevices() const
{
    QVariantList variantList;
    for (auto it = _favoriteDevices.begin(); it != _favoriteDevices.end(); ++it) {
        QVariantMap item;
        item["address"] = it.key();
        item["name"] = it.value();
        variantList.append(item);
    }
    return variantList;
}

QVariant ClientManager::services() const
{
    return QVariant::fromValue(_allServices.values());
}

QVariantMap ClientManager::characteristics() const
{
    QVariantMap chars;
    auto srvUuidList = _allCharacteristics.keys();
    for (auto &srvUuid : srvUuidList) {
        auto charList = _allCharacteristics.value(srvUuid).values();
        chars[srvUuid] = QVariant::fromValue(charList);
    }
    return chars;
}

QVariantMap ClientManager::descriptors() const
{
    QVariantMap descs;
    auto charUuidList = _allDescriptors.keys();
    for (auto &charUuid : charUuidList) {
        auto descList = _allDescriptors.value(charUuid).values();
        descs[charUuid] = QVariant::fromValue(descList);
    }
    return descs;
}

QVariantList ClientManager::serviceUuidDictionary() const
{
    QVariantList variantList;
    for (auto it = _serviceUuidDictionary.begin(); it != _serviceUuidDictionary.end(); ++it) {
        QVariantMap item;
        item["uuid"] = it.key();
        item["name"] = it.value();
        variantList.append(item);
    }
    return variantList;
}

QVariantList ClientManager::characteristicUuidDictionary() const
{
    QVariantList variantList;
    for (auto it = _characteristicUuidDictionary.begin(); it != _characteristicUuidDictionary.end();
         ++it) {
        QVariantMap item;
        item["uuid"] = it.key();
        item["name"] = it.value();
        variantList.append(item);
    }
    return variantList;
}

void ClientManager::refreshAllAttributesName()
{
    if (!_isDeviceConnected) {
        return;
    }

    for (auto it = _allServices.begin(); it != _allServices.end(); ++it) {
        QString srvUuid = it.key();
        ServiceInfo *srvInfo = it.value();

        QString newName;

        if (_isUuidNameMappingEnabled && _serviceUuidDictionary.contains(srvUuid)) {
            newName = _serviceUuidDictionary[srvUuid];
        } else {
            newName = Utils::getAttributeName(srvInfo->service());
        }
        srvInfo->name(newName);

        QMap<QString, CharacteristicInfo *> chars = _allCharacteristics[srvUuid];
        for (auto charIt = chars.begin(); charIt != chars.end(); ++charIt) {
            QString charUuid = charIt.key();
            CharacteristicInfo *charInfo = charIt.value();

            if (_isUuidNameMappingEnabled && _characteristicUuidDictionary.contains(charUuid)) {
                newName = _characteristicUuidDictionary[charUuid];
            } else {
                newName = Utils::getAttributeName(charInfo->characteristic());
            }
            charInfo->name(newName);
        }
    }
}

void ClientManager::initializeVariables()
{
    filterParams(new FilterParams(this));
    isDeviceConnected(false);
    connectedDeviceInfo(nullptr);

    clearAllDevices();
    clearAllAttributes(true);

    scanTimeout(_settingsManager->scanTimeout());
    connect(this, &ClientManager::scanTimeoutChanged, this, &ClientManager::updateScanTimeout);

    isUuidNameMappingEnabled(_settingsManager->isUuidNameMappingEnabled());
    connect(this, &ClientManager::isUuidNameMappingEnabledChanged, this,
            &ClientManager::refreshAllAttributesName);
}

void ClientManager::loadFavouriteDevices()
{
    _favoriteDevices = _settingsManager->favoriteDevices();
    emit favoriteDevicesChanged();
}

void ClientManager::loadUuidDictionary()
{
    _serviceUuidDictionary = _settingsManager->serviceUuidDictionary();
    _characteristicUuidDictionary = _settingsManager->characteristicUuidDictionary();
}

void ClientManager::initLocalDevice()
{
    _localDevice = new QBluetoothLocalDevice(this);

    connect(_localDevice, &QBluetoothLocalDevice::errorOccurred, this,
            &ClientManager::localDeviceError);
    connect(_localDevice, &QBluetoothLocalDevice::hostModeStateChanged, this,
            &ClientManager::hostModeChanged);
    connect(_localDevice, &QBluetoothLocalDevice::pairingFinished, this,
            &ClientManager::pairingFinished);

    emit isBluetoothOnChanged();
}

void ClientManager::initDeviceDiscoveryAgent()
{
    _deviceDiscoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);
    _deviceDiscoveryAgent->setLowEnergyDiscoveryTimeout(_scanTimeout);

    connect(_deviceDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::errorOccurred, this,
            &ClientManager::discoveryAgentError);
    connect(_deviceDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered, this,
            &ClientManager::addDevice);
    connect(_deviceDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated, this,
            &ClientManager::updateDevice);
    connect(_deviceDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished, this,
            &ClientManager::deviceScanFinished);
    connect(_deviceDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::canceled, this,
            &ClientManager::deviceScanFinished);
}

void ClientManager::addDeviceToFiltered(DeviceInfo *device)
{
    QString filterName = _filterParams->name();
    QString filterAddress = _filterParams->address();
    int filterRssiValue = _filterParams->rssiValue();

    bool nameMatches = filterName.isEmpty() || device->name() == filterName;
    bool addressMatches = filterAddress.isEmpty() || device->address() == filterAddress;
    bool rssiMatches = device->rssi() >= filterRssiValue;
    bool favouriteMatches =
            !_filterParams->isOnlyFavourite() || _favoriteDevices.contains(device->address());
    bool connectedMatches = !_filterParams->isOnlyConnected() || device->isConnected();
    bool pairedMatches = !_filterParams->isOnlyPaired() || device->isPaired();

    if (nameMatches && addressMatches && rssiMatches && favouriteMatches && connectedMatches
        && pairedMatches) {
        _filteredDevices.append(device);
    }
}

void ClientManager::clearAllDevices()
{
    QList<QString> devAddrToRemove;
    for (auto it = _allDevices.begin(); it != _allDevices.end(); ++it) {
        auto devAddr = it.key();
        auto devInfo = it.value();
        if (_connectedDeviceInfo && _connectedDeviceInfo->isConnected()
            && _connectedDeviceInfo->address() == devAddr) {
            continue; // 已连接的设备不删除
        }

        delete devInfo;
        devAddrToRemove.append(devAddr);
    }
    for (const auto &devAddr : devAddrToRemove) {
        _allDevices.remove(devAddr);
    }
}

void ClientManager::clearAllAttributes(bool emitChangedSignals)
{
    qDeleteAll(_allServices);
    _allServices.clear();

    for (auto it = _allCharacteristics.begin(); it != _allCharacteristics.end(); ++it) {
        QMap<QString, CharacteristicInfo *> &chars = it.value();
        qDeleteAll(chars);
    }
    _allCharacteristics.clear();

    for (auto it = _allDescriptors.begin(); it != _allDescriptors.end(); ++it) {
        QMap<QString, DescriptorInfo *> &descs = it.value();
        qDeleteAll(descs);
    }
    _allDescriptors.clear();

    if (emitChangedSignals) {
        emit servicesChanged();
        emit characteristicsChanged();
        emit descriptorsChanged();
    }
}

void ClientManager::localDeviceError(QBluetoothLocalDevice::Error error)
{
    switch (error) {
    case QBluetoothLocalDevice::PairingError:
        emit errorOccurred(PairingError);
        showError("Local device error: %s", "PairingError");
        break;
    case QBluetoothLocalDevice::UnknownError:
        emit errorOccurred(UnknownError);
        showError("Local device error: %s", "UnknownError");
        break;
    default:
        break;
    }
}

void ClientManager::hostModeChanged(QBluetoothLocalDevice::HostMode mode)
{
    if (isScanning()) {
        stopScan();
    }
    emit isBluetoothOnChanged();
    emit isScanningChanged();
}

void ClientManager::pairingFinished(const QBluetoothAddress &address,
                                    QBluetoothLocalDevice::Pairing pairing)
{
    auto addr = address.toString();
    if (!_allDevices.contains(addr)) {
        return;
    }
    auto devInfo = _allDevices[addr];

    switch (pairing) {
    case QBluetoothLocalDevice::Unpaired:
        devInfo->isPaired(false);
        showInfo("Unpaired: %s, %s", devInfo->address().toStdString().c_str(),
                 devInfo->name().toStdString().c_str());
        break;
    case QBluetoothLocalDevice::Paired:
    case QBluetoothLocalDevice::AuthorizedPaired:
        devInfo->isPaired(true);
        showInfo("Paired: %s, %s", devInfo->address().toStdString().c_str(),
                 devInfo->name().toStdString().c_str());
        break;
    default:
        break;
    }

    emit requestPairingSucceeded(devInfo);
}

void ClientManager::discoveryAgentError(QBluetoothDeviceDiscoveryAgent::Error error)
{
    switch (error) {
    case QBluetoothDeviceDiscoveryAgent::PoweredOffError:
        emit errorOccurred(PoweredOffError);
        showError("Discovery agent error: %s", "PoweredOffError");
        break;
    case QBluetoothDeviceDiscoveryAgent::UnknownError:
        emit errorOccurred(UnknownError);
        showError("Discovery agent error: %s", "UnknownError");
        break;
    default:
        break;
    }
}

void ClientManager::addDevice(const QBluetoothDeviceInfo &info)
{
    if (info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration) {
        auto devInfo = new DeviceInfo(info);
        QString address = devInfo->address();

        bool isFavorite = _favoriteDevices.contains(address);
        bool isPaired = _localDevice
                && _localDevice->pairingStatus(info.address()) != QBluetoothLocalDevice::Unpaired;

        devInfo->isFavorite(isFavorite);
        devInfo->isPaired(isPaired);

        auto it = std::find_if(
                _filteredDevices.begin(), _filteredDevices.end(),
                [devInfo](DeviceInfo *dev) { return devInfo->address() == dev->address(); });

        if (it == _filteredDevices.end()) {
            addDeviceToFiltered(devInfo);
        } else {
            *it = devInfo;
        }

        if (!_allDevices.contains(address)) {
            _allDevices.insert(address, devInfo);
        } else {
            auto oldDev = _allDevices[address];
            _allDevices[address] = devInfo;
            delete oldDev;
        }

        emit filteredDevicesChanged();

        showInfo("Low Energy device found. Scanning more...");
    }
}

void ClientManager::updateDevice(const QBluetoothDeviceInfo &info,
                                 QBluetoothDeviceInfo::Fields updatedFields)
{
    auto devAddr = info.address().toString();
    if (!_allDevices.contains(devAddr)) {
        return;
    }

    showInfo("Update device: %s, %s", devAddr.toStdString().c_str(),
             info.name().toStdString().c_str());
    auto devInfo = _allDevices[devAddr];
    devInfo->update(info);
}

void ClientManager::deviceScanFinished()
{
    if (_allDevices.isEmpty()) {
        showError("No Low Energy devices found");
    } else {
        showInfo("Device scan finished");
    }

    emit isScanningChanged();
    emit filteredDevicesChanged();
}

void ClientManager::updateScanTimeout()
{
    if (_deviceDiscoveryAgent) {
        showInfo("Update scan timeout: %d ms", _scanTimeout);
        _deviceDiscoveryAgent->setLowEnergyDiscoveryTimeout(_scanTimeout);
    }
}

void ClientManager::controllerError(QLowEnergyController::Error error)
{
    showError(_lowEnergyController->errorString().toStdString().c_str());

    switch (error) {
    case QLowEnergyController::ConnectionError:
        emit errorOccurred(ConnectionError);
        break;
    case QLowEnergyController::RemoteHostClosedError:
        emit errorOccurred(RemoteHostClosedError);
        break;
    case QLowEnergyController::UnknownError:
        emit errorOccurred(UnknownError);
        break;
    default:
        break;
    }
}

void ClientManager::controllerConnected()
{
    showInfo("Controller has connected");

    isDeviceConnected(true);

    if (_currentSelectedDeviceInfo) {
        _currentSelectedDeviceInfo->isConnected(true);
    }
    connectedDeviceInfo(_currentSelectedDeviceInfo);

    showInfo("Discovering services...");
    _lowEnergyController->discoverServices();
}

void ClientManager::controllerDisconnected()
{
    showInfo("Controller has disconnected");

    if (_lowEnergyController) {
        delete _lowEnergyController;
        _lowEnergyController = nullptr;
    }

    isDeviceConnected(false);

    if (_connectedDeviceInfo) {
        _connectedDeviceInfo->isConnected(false);
        connectedDeviceInfo(nullptr);
    }

    clearAllAttributes(true);
}

void ClientManager::addService(const QBluetoothUuid &serviceUuid)
{
    QLowEnergyService *service = _lowEnergyController->createServiceObject(serviceUuid);
    if (service == nullptr) {
        return;
    }

    ServiceInfo *srvInfo = new ServiceInfo(service);
    auto srvUuid = srvInfo->uuid();

    if (_isUuidNameMappingEnabled && _serviceUuidDictionary.contains(srvUuid)) {
        srvInfo->name(_serviceUuidDictionary[srvUuid]);
    }

    if (_allServices.contains(srvUuid)) {
        auto oldSrv = _allServices[srvUuid];
        _allServices[srvUuid] = srvInfo;
        delete oldSrv;
        showInfo("Update Service: %s", srvUuid.toStdString().c_str());
    } else {
        _allServices.insert(srvUuid, srvInfo);
        showInfo("Add Service: %s", srvUuid.toStdString().c_str());
    }

    emit servicesChanged();
}

void ClientManager::serviceScanFinished()
{
    showInfo("Service scan finished!");
    if (_allServices.isEmpty()) {
        showError("No services found");
        return;
    }

    showInfo("Service discovery done");

    auto srvInfos = _allServices.values();
    for (auto info : srvInfos) {
        auto srv = info->service();

        connect(srv, &QLowEnergyService::errorOccurred, this, &ClientManager::serviceError);
        connect(srv, &QLowEnergyService::stateChanged, this, &ClientManager::serviceStateChanged);
        connect(srv, &QLowEnergyService::characteristicRead, this,
                &ClientManager::characteristicRead);
        connect(srv, &QLowEnergyService::characteristicChanged, this,
                &ClientManager::characteristicChanged);
        connect(srv, &QLowEnergyService::characteristicWritten, this,
                &ClientManager::characteristicWritten);
        connect(srv, &QLowEnergyService::descriptorRead, this, &ClientManager::descriptorRead);
        connect(srv, &QLowEnergyService::descriptorWritten, this,
                &ClientManager::descriptorWritten);

        srv->discoverDetails(QLowEnergyService::SkipValueDiscovery);
    }
}

void ClientManager::serviceError(QLowEnergyService::ServiceError error)
{
    switch (error) {
    case QLowEnergyService::OperationError:
        emit errorOccurred(OperationError);
        showError("Service error: %s", "OperationError");
        break;
    case QLowEnergyService::CharacteristicWriteError:
        emit errorOccurred(CharacteristicWriteError);
        showError("Service error: %s", "CharacteristicWriteError");
        break;
    case QLowEnergyService::DescriptorWriteError:
        emit errorOccurred(DescriptorWriteError);
        showError("Service error: %s", "DescriptorWriteError");
        break;
    case QLowEnergyService::CharacteristicReadError:
        emit errorOccurred(CharacteristicReadError);
        showError("Service error: %s", "CharacteristicReadError");
        break;
    case QLowEnergyService::DescriptorReadError:
        emit errorOccurred(DescriptorReadError);
        showError("Service error: %s", "DescriptorReadError");
        break;
    case QLowEnergyService::UnknownError:
        emit errorOccurred(UnknownError);
        showError("Service error: %s", "UnknownError");
        break;
    default:
        break;
    }
}

void ClientManager::serviceStateChanged(QLowEnergyService::ServiceState state)
{
    switch (state) {
    case QLowEnergyService::RemoteServiceDiscovering:
        showInfo("Discovering services...");
        break;
    case QLowEnergyService::RemoteServiceDiscovered: {
        auto service = qobject_cast<QLowEnergyService *>(sender());
        if (service == nullptr) {
            break;
        }

        auto srvUuid = Utils::uuidToString(service->serviceUuid());
        if (_allCharacteristics.contains(srvUuid)) {
            auto oldCharUuids = _allCharacteristics.value(srvUuid).keys();
            auto oldCharInfos = _allCharacteristics.value(srvUuid).values();
            qDeleteAll(oldCharInfos);

            for (auto &charUuid : oldCharUuids) {
                auto oldDescInfos = _allDescriptors.value(charUuid).values();
                qDeleteAll(oldDescInfos);
                _allDescriptors.remove(charUuid);
            }

            _allServices.remove(srvUuid);
        }

        auto chars = service->characteristics();
        for (auto &ch : chars) {
            auto charInfo = new CharacteristicInfo(ch);
            auto charUuid = charInfo->uuid();

            if (_isUuidNameMappingEnabled && _characteristicUuidDictionary.contains(charUuid)) {
                charInfo->name(_characteristicUuidDictionary[charUuid]);
            }

            _allCharacteristics[srvUuid][charUuid] = charInfo;

            auto descs = ch.descriptors();
            for (auto &d : descs) {
                auto descInfo = new DescriptorInfo(d);
                auto descUuid = descInfo->uuid();
                _allDescriptors[charUuid][descUuid] = descInfo;
            }
        }

        emit characteristicsChanged();
        emit descriptorsChanged();

        showInfo("Service %s discover done", srvUuid.toStdString().c_str());

        break;
    }
    default:
        break;
    }
}

void ClientManager::characteristicChanged(const QLowEnergyCharacteristic &characteristic,
                                          const QByteArray &value)
{
}

void ClientManager::characteristicRead(const QLowEnergyCharacteristic &characteristic,
                                       const QByteArray &value)
{
}

void ClientManager::characteristicWritten(const QLowEnergyCharacteristic &characteristic,
                                          const QByteArray &value)
{
}

void ClientManager::descriptorRead(const QLowEnergyDescriptor &descriptor, const QByteArray &value)
{
}

void ClientManager::descriptorWritten(const QLowEnergyDescriptor &descriptor,
                                      const QByteArray &value)
{
}
