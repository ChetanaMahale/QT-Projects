#pragma once

#include <QObject>
#include <QString>
#include <QStringList>

class CalculatorEngine : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString displayText READ displayText NOTIFY displayTextChanged)
    Q_PROPERTY(QString expressionText READ expressionText NOTIFY expressionTextChanged)
    Q_PROPERTY(QStringList history READ history NOTIFY historyChanged)
    Q_PROPERTY(bool hasError READ hasError NOTIFY hasErrorChanged)

public:
    explicit CalculatorEngine(QObject *parent = nullptr);

    QString displayText() const;
    QString expressionText() const;
    QStringList history() const;
    bool hasError() const;

public slots:
    void inputDigit(const QString &digit);
    void inputOperator(const QString &op);
    void inputDecimal();
    void calculate();
    void clear();
    void clearAll();
    void backspace();
    void toggleSign();
    void percentage();
    void inputSpecial(const QString &func);

signals:
    void displayTextChanged();
    void expressionTextChanged();
    void historyChanged();
    void hasErrorChanged();
    void animateResult();

private:
    void setDisplay(const QString &text);
    void setExpression(const QString &text);
    double applyOperator(double a, double b, const QString &op);
    bool isOperator(const QString &s);

    QString m_displayText;
    QString m_expressionText;
    QStringList m_history;
    bool m_hasError;

    double m_operand;
    QString m_operator;
    bool m_waitingForOperand;
    bool m_justCalculated;
    QString m_lastExpression;
};
