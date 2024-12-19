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

const QLowEnergyDescriptor &DescriptorInfo::descriptor() const
{
    return _descriptor;
}
