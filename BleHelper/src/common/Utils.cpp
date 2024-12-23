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

QString Utils::byteArrayToHex(const QByteArray &value, char separator, bool upper)
{
    QString result = value.toHex(separator);
    if (upper) {
        result = result.toUpper();
    } else {
        result = result.toLower();
    }
    return result;
}

QString Utils::byteArrayToAscii(const QByteArray &value)
{
    QByteArray v = value + '\0';
    QString result = QString(v.data());
    return result;
}

QString Utils::byteArrayToDecimal(const QByteArray &value, char separator)
{
    QString result;
    for (char byte : value) {
        result += QString::number(static_cast<unsigned char>(byte)) + separator;
    }
    result = result.trimmed();
    return result;
}

QString Utils::parseDescriptorValue(const QByteArray &value, QBluetoothUuid::DescriptorType type)
{
    if (value.isEmpty()) {
        return "";
    }

    if (QBluetoothUuid::DescriptorType::CharacteristicExtendedProperties == type) {
        unsigned char firstByte = static_cast<unsigned char>(value[0]);
        QStringList result;

        if (firstByte & 0b00000001) {
            result.append("Reliable write enabled");
        } else {
            result.append("Reliable write disabled");
        }

        if (firstByte & 0b00000010) {
            result.append("Writable auxiliaries enabled");
        } else {
            result.append("Writable auxiliaries disabled");
        }

        QString formattedResult = result.join(", ");
        return formattedResult;
    } else if (QBluetoothUuid::DescriptorType::CharacteristicUserDescription == type) {
        return byteArrayToAscii(value);
    } else if (QBluetoothUuid::DescriptorType::ClientCharacteristicConfiguration == type) {
        unsigned char firstByte = static_cast<unsigned char>(value[0]);
        QString result;

        if (firstByte & 0b00000001) {
            result = "Notifications enabled";
        } else if (firstByte & 0b00000010) {
            result = "Indications enabled";
        } else if (firstByte == 0b00000000) {
            result = "Notifications and indications disabled";
        }

        return result;
    } else if (QBluetoothUuid::DescriptorType::ServerCharacteristicConfiguration == type) {
        unsigned char firstByte = static_cast<unsigned char>(value[0]);

        if (firstByte & 0b00000001) {
            return "Broadcasts enabled";
        } else {
            return "Broadcasts disabled";
        }
    } else if (QBluetoothUuid::DescriptorType::ReportReference == type) {
        if (value.size() != 2) {
            return "Unknown value: 0x" + byteArrayToHex(value);
        } else {
            char reportId = value[0];
            char reportType = value[1];

            QString result;
            result += "Report ID: ";
            result += byteArrayToHex(QByteArray(1, reportId));
            result += ", ";
            result += "Report Type: ";
            result += byteArrayToHex(QByteArray(1, reportType));

            return result;
        }
    }

    return byteArrayToHex(value);
}
