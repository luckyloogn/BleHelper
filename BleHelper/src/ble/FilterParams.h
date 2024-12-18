#pragma once

#include <QObject>
#include <QString>

#include "stdafx.h"

class FilterParams : public QObject
{
    Q_OBJECT

    Q_PROPERTY_AUTO(QString, name)
    Q_PROPERTY_AUTO(QString, address)
    Q_PROPERTY_AUTO(int, rssiValue)
    Q_PROPERTY_AUTO(bool, isOnlyFavourite)
    Q_PROPERTY_AUTO(bool, isOnlyConnected)
    Q_PROPERTY_AUTO(bool, isOnlyPaired)

public:
    explicit FilterParams(QObject *parent = nullptr);
};
