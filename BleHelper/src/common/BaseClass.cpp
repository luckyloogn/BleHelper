#include <QDebug>

#include "BaseClass.h"

BaseClass::BaseClass(QObject *parent) : QObject(parent) { }

void BaseClass::showError(const char *format, ...)
{
    va_list args;
    va_start(args, format);

    QString str = QString::vasprintf(format, args);

    qDebug() << "\033[31m" << qPrintable(str) << "\033[0m";

    va_end(args);
}

void BaseClass::showWarning(const char *format, ...)
{
    va_list args;
    va_start(args, format);

    QString str = QString::vasprintf(format, args);

    qDebug() << "\033[33m" << qPrintable(str) << "\033[0m";

    va_end(args);
}

void BaseClass::showInfo(const char *format, ...)
{
    va_list args;
    va_start(args, format);

    QString str = QString::vasprintf(format, args);

    qDebug() << "\033[32m" << qPrintable(str) << "\033[0m";

    va_end(args);
}
