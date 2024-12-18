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
