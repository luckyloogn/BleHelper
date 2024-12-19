#include "ServiceInfo.h"
#include "Utils.h"

ServiceInfo::ServiceInfo(QLowEnergyService *s)
{
    if (s == nullptr) {
        return;
    }

    _service = s;
    _service->setParent(this);

    /* name */
    _name = Utils::getAttributeName(s, &_canRename);
    emit nameChanged();
    emit canRenameChanged();

    /* uuid */
    uuid(Utils::uuidToString(s->serviceUuid()));

    /* type */
    switch (s->type()) {
    case QLowEnergyService::PrimaryService:
        type("Primary Service");
        break;
    case QLowEnergyService::IncludedService:
        type("Secondary Service");
        break;
    default:
        type("Unknown Service");
        break;
    }
}

QLowEnergyService *ServiceInfo::service() const
{
    return _service;
}
