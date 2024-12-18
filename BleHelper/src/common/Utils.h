#pragma once

#include <QBluetoothUuid>
#include <QString>

class Utils
{
public:
    static QString uuidToString(const QBluetoothUuid &uuid);
};
