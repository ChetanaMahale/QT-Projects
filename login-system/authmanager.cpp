#include "authmanager.h"
#include <QRegularExpression>

AuthManager::AuthManager(QObject *parent)
    : QObject(parent)
    , m_currentUser("")
    , m_isLoggedIn(false)
{
    // Seed with a default demonstration user
    registerUser("admin", "admin@example.com", "Password123");
}

QString AuthManager::currentUser() const
{
    return m_currentUser;
}

bool AuthManager::isLoggedIn() const
{
    return m_isLoggedIn;
}

bool AuthManager::login(const QString &usernameOrEmail, const QString &password)
{
    QString input = usernameOrEmail.trimmed().toLower();
    QString targetUsername = input;

    // Resolve username if email is entered
    if (m_emailToUsername.contains(input)) {
        targetUsername = m_emailToUsername[input];
    }

    if (!m_usersByUsername.contains(targetUsername)) {
        emit loginError("User does not exist.");
        return false;
    }

    const User &user = m_usersByUsername[targetUsername];
    if (user.password != password) {
        emit loginError("Incorrect password.");
        return false;
    }

    m_currentUser = user.username;
    m_isLoggedIn = true;
    emit currentUserChanged();
    emit isLoggedInChanged();
    emit loginSuccess(m_currentUser);
    return true;
}

bool AuthManager::registerUser(const QString &username, const QString &email, const QString &password)
{
    QString uName = username.trimmed();
    QString uNameLower = uName.toLower();
    QString eMail = email.trimmed().toLower();

    if (uName.length() < 3) {
        emit registrationError("Username must be at least 3 characters.");
        return false;
    }

    if (!isValidEmail(eMail)) {
        emit registrationError("Please enter a valid email address.");
        return false;
    }

    if (password.length() < 6) {
        emit registrationError("Password must be at least 6 characters.");
        return false;
    }

    if (m_usersByUsername.contains(uNameLower)) {
        emit registrationError("Username is already taken.");
        return false;
    }

    if (m_emailToUsername.contains(eMail)) {
        emit registrationError("Email is already registered.");
        return false;
    }

    User newUser;
    newUser.username = uName;
    newUser.email = eMail;
    newUser.password = password;

    m_usersByUsername[uNameLower] = newUser;
    m_emailToUsername[eMail] = uNameLower;

    emit registrationSuccess();
    return true;
}

void AuthManager::logout()
{
    if (!m_isLoggedIn) return;

    m_currentUser = "";
    m_isLoggedIn = false;
    emit currentUserChanged();
    emit isLoggedInChanged();
}

int AuthManager::checkPasswordStrength(const QString &password) const
{
    if (password.length() < 6) return 0; // Weak

    bool hasUpper = false;
    bool hasLower = false;
    bool hasDigit = false;
    bool hasSpecial = false;

    QRegularExpression upperRegex("[A-Z]");
    QRegularExpression lowerRegex("[a-z]");
    QRegularExpression digitRegex("[0-9]");
    QRegularExpression specialRegex("[^a-zA-Z0-9]");

    if (upperRegex.match(password).hasMatch()) hasUpper = true;
    if (lowerRegex.match(password).hasMatch()) hasLower = true;
    if (digitRegex.match(password).hasMatch()) hasDigit = true;
    if (specialRegex.match(password).hasMatch()) hasSpecial = true;

    int criteriaMet = (hasUpper ? 1 : 0) + (hasLower ? 1 : 0) + (hasDigit ? 1 : 0) + (hasSpecial ? 1 : 0);

    if (criteriaMet >= 4 && password.length() >= 10) {
        return 2; // Strong
    } else if (criteriaMet >= 3 && password.length() >= 8) {
        return 2; // Strong
    } else if (criteriaMet >= 2) {
        return 1; // Medium
    }

    return 0; // Weak
}

bool AuthManager::isValidEmail(const QString &email) const
{
    // Basic email validation regex
    QRegularExpression regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");
    return regex.match(email).hasMatch();
}
