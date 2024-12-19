#include "Utils.h"

QString Utils::uuidToString(const QBluetoothUuid &uuid)
{
    bool success = false;
    quint16 result16 = uuid.toUInt16(&success);
    if (success) {
        return "0x" + QString::number(result16, 16).toUpper();
    }

    quint32 result32 = uuid.toUInt32(&success);
    if (success) {
        return "0x" + QString::number(result32, 16).toUpper();
    }

    return uuid.toString().remove('{').remove('}').toUpper();
}

QString Utils::getAttributeName(const QLowEnergyService *s, bool *canRename)
{
    if (!s) {
        return QString();
    }

    if (canRename) {
        *canRename = s->serviceName() == "Unknown Service" || s->serviceName().isEmpty();
    }

    return s->serviceName();
}

QString Utils::getAttributeName(const QLowEnergyCharacteristic &c, bool *canRename)
{
    QString name = c.name();
    if (!name.isEmpty()) {
        if (canRename) {
            *canRename = false;
        }
        return name;
    }

    // 使用CharacteristicUserDescription更新命名需要:
    // 在调用QLowEnergyService::discoverDetails()时不能将参数mode设置为QLowEnergyService::SkipValueDiscovery
    // 或者在调用QLowEnergyService::readDescriptor()后再调用此函数
    const QList<QLowEnergyDescriptor> descriptors = c.descriptors();
    for (const QLowEnergyDescriptor &descriptor : descriptors) {
        if (descriptor.type() == QBluetoothUuid::DescriptorType::CharacteristicUserDescription) {
            name = descriptor.value();
            break;
        }
    }

    if (name.isEmpty()) {
        name = "Unknown Characteristic";
    }

    if (canRename) {
        *canRename = true;
    }
    return name;
}

QString Utils::getAttributeName(const QLowEnergyDescriptor &d, bool *canRename)
{
    QString name = d.name();

    if (canRename) {
        *canRename = name.isEmpty();
    }

    if (name.isEmpty()) {
        name = "Unknown Descriptor";
    }

    return name;
}
