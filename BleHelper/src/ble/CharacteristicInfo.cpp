#include "CharacteristicInfo.h"
#include "Utils.h"

#include <QBluetoothUuid>
#include <QByteArray>

CharacteristicInfo::CharacteristicInfo(const QLowEnergyCharacteristic &c)
{
    _characteristic = c;

    /* name */
    _name = Utils::getAttributeName(c, &_canRename);
    emit nameChanged();
    emit canRenameChanged();

    /* uuid */
    uuid(Utils::uuidToString(c.uuid()));

    /* properties */
    canIndicate(false);
    canNotify(false);
    canRead(false);
    canWrite(false);
    canWriteNoResponse(false);

    QString tmp = "";
    uint p = c.properties();
    if (p & QLowEnergyCharacteristic::Indicate) {
        tmp += ", Indicate";
        canIndicate(true);
    }
    if (p & QLowEnergyCharacteristic::Notify) {
        tmp += ", Notify";
        canNotify(true);
    }
    if (p & QLowEnergyCharacteristic::Read) {
        tmp += ", Read";
        canRead(true);
    }
    if (p & QLowEnergyCharacteristic::Write) {
        tmp += ", Write";
        canWrite(true);
    }
    if (p & QLowEnergyCharacteristic::WriteNoResponse) {
        tmp += ", WriteNoResponse";
        canWriteNoResponse(true);
    }
    if (p & QLowEnergyCharacteristic::ExtendedProperty) {
        tmp += ", ExtendedProperty";
    }
    if (p & QLowEnergyCharacteristic::Broadcasting) {
        tmp += ", Broadcast";
    }
    if (p & QLowEnergyCharacteristic::WriteSigned) {
        tmp += ", WriteSigned";
    }
    if (p == QLowEnergyCharacteristic::Unknown) {
        tmp = "Unknown";
    } else {
        // 去掉开头的 ", "
        tmp.removeAt(0);
        tmp.removeAt(0);
    }
    properties(tmp);

    /* value */
    valueHex("");
    valueAscii("");
    valueDecimal("");

    /* indications & notifications settings */
    enableIndications(false);
    enableNotifications(false);
}

const QLowEnergyCharacteristic &CharacteristicInfo::characteristic() const
{
    return _characteristic;
}
