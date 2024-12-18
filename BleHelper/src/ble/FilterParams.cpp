#include "FilterParams.h"

FilterParams::FilterParams(QObject *parent) : QObject(parent)
{
    name("");
    address("");
    rssiValue(-130);
    isOnlyFavourite(false);
    isOnlyConnected(false);
    isOnlyPaired(false);
}
