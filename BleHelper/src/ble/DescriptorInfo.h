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

public:
    DescriptorInfo() = default;
    DescriptorInfo(const QLowEnergyDescriptor &d);

    QLowEnergyDescriptor getQLowEnergyDescriptor() const;

private:
    QLowEnergyDescriptor _descriptor;
};
