#include "DescriptorInfo.h"
#include "Utils.h"

DescriptorInfo::DescriptorInfo(const QLowEnergyDescriptor &d)
{
    _descriptor = d;

    /* name */
    _name = Utils::getAttributeName(d, &_canRename);
    emit nameChanged();
    emit canRenameChanged();

    /* uuid */
    uuid(Utils::uuidToString(d.uuid()));
}

QLowEnergyDescriptor DescriptorInfo::getQLowEnergyDescriptor() const
{
    return _descriptor;
}
