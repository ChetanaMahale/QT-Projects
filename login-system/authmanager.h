#pragma once

#include <QObject>
#include <QString>
#include <QMap>

struct User {
    QString username;
    QString email;
    QString password; // In a production app, we would hash this (e.g. bcrypt/PBKDF2)
};

class AuthManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString currentUser READ currentUser NOTIFY currentUserChanged)
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY isLoggedInChanged)

public:
    explicit AuthManager(QObject *parent = nullptr);

    QString currentUser() const;
    bool isLoggedIn() const;

public slots:
    bool login(const QString &usernameOrEmail, const QString &password);
    bool registerUser(const QString &username, const QString &email, const QString &password);
    void logout();
    int checkPasswordStrength(const QString &password) const; // Returns 0=weak, 1=medium, 2=strong

signals:
    void currentUserChanged();
    void isLoggedInChanged();
    void loginSuccess(const QString &username);
    void loginError(const QString &message);
    void registrationSuccess();
    void registrationError(const QString &message);

private:
    bool isValidEmail(const QString &email) const;

    QMap<QString, User> m_usersByUsername; // Key: Lowercase Username
    QMap<QString, QString> m_emailToUsername; // Key: Lowercase Email, Value: Lowercase Username
    QString m_currentUser;
    bool m_isLoggedIn;
};
