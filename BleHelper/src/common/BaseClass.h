#pragma once

#include <QObject>

class BaseClass : public QObject
{
    Q_OBJECT

public:
    explicit BaseClass(QObject *parent = nullptr);

protected:
    void showError(const char *format, ...);
    void showWarning(const char *format, ...);
    void showInfo(const char *format, ...);
};
