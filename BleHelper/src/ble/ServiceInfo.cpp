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
    name(s->serviceName());
    if (s->serviceName() == "Unknown Service" || s->serviceName().isEmpty()) {
        canRename(true);
    } else {
        canRename(false);
    }

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

QLowEnergyService *ServiceInfo::getQLowEnergyService() const
{
    return _service;
}
