#pragma once

#include <QLowEnergyDescriptor>
#include <QObject>
#include <QString>

#include "stdafx.h"

class DescriptorInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY_READONLY_AUTO(QString, name)
    Q_PROPERTY_READONLY_AUTO(QString, uuid)
    Q_PROPERTY_READONLY_AUTO(bool, canRename)
    Q_PROPERTY_READONLY_AUTO(QString, value)

public:
    DescriptorInfo() = default;
    DescriptorInfo(const QLowEnergyDescriptor &d);

    const QLowEnergyDescriptor &descriptor() const;

private:
    QLowEnergyDescriptor _descriptor;
};
