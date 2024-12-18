#include "DescriptorInfo.h"
#include "Utils.h"

DescriptorInfo::DescriptorInfo(const QLowEnergyDescriptor &d)
{
    _descriptor = d;

    /* name */
    name(d.name());

    /* uuid */
    uuid(Utils::uuidToString(d.uuid()));
}

QLowEnergyDescriptor DescriptorInfo::getQLowEnergyDescriptor() const
{
    return _descriptor;
}
