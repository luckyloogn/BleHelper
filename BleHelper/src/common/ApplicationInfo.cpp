#include "ApplicationInfo.h"
#include "BuildConfig.h"

ApplicationInfo::ApplicationInfo(QObject *parent) : QObject(parent)
{
    applicationName(APPLICATION_NAME);
    versionName(VERSION_NAME);
    buildDateTime(BUILD_DATE_TIME);
    author(AUTHOR);
    repositoryUrl(REPOSITORY_URL);
    updateCheckUrl(UPDATE_CHECK_URL);
    updateUrl(UPDATE_URL);
}

ApplicationInfo::~ApplicationInfo() = default;
