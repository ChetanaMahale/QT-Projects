#include "calculatorengine.h"
#include <QDebug>
#include <cmath>

CalculatorEngine::CalculatorEngine(QObject *parent)
    : QObject(parent)
    , m_displayText("0")
    , m_expressionText("")
    , m_hasError(false)
    , m_operand(0.0)
    , m_operator("")
    , m_waitingForOperand(false)
    , m_justCalculated(false)
{
}

QString CalculatorEngine::displayText() const { return m_displayText; }
QString CalculatorEngine::expressionText() const { return m_expressionText; }
QStringList CalculatorEngine::history() const { return m_history; }
bool CalculatorEngine::hasError() const { return m_hasError; }

void CalculatorEngine::setDisplay(const QString &text)
{
    if (m_displayText != text) {
        m_displayText = text;
        emit displayTextChanged();
    }
}

void CalculatorEngine::setExpression(const QString &text)
{
    if (m_expressionText != text) {
        m_expressionText = text;
        emit expressionTextChanged();
    }
}

void CalculatorEngine::inputDigit(const QString &digit)
{
    if (m_hasError) clearAll();

    if (m_waitingForOperand || m_justCalculated) {
        setDisplay(digit);
        m_waitingForOperand = false;
        m_justCalculated = false;
    } else {
        if (m_displayText == "0") {
            setDisplay(digit);
        } else {
            if (m_displayText.length() < 15) {
                setDisplay(m_displayText + digit);
            }
        }
    }
}

void CalculatorEngine::inputDecimal()
{
    if (m_hasError) clearAll();

    if (m_waitingForOperand || m_justCalculated) {
        setDisplay("0.");
        m_waitingForOperand = false;
        m_justCalculated = false;
        return;
    }
    if (!m_displayText.contains('.')) {
        setDisplay(m_displayText + ".");
    }
}

void CalculatorEngine::inputOperator(const QString &op)
{
    if (m_hasError) return;

    double current = m_displayText.toDouble();

    if (!m_operator.isEmpty() && !m_waitingForOperand) {
        // Chain calculation
        double result = applyOperator(m_operand, current, m_operator);
        if (std::isnan(result) || std::isinf(result)) {
            setDisplay("Error");
            setExpression("");
            m_hasError = true;
            emit hasErrorChanged();
            return;
        }
        m_operand = result;
        QString formatted = QString::number(result, 'g', 12);
        setDisplay(formatted);
        setExpression(formatted + " " + op);
    } else {
        m_operand = current;
        setExpression(m_displayText + " " + op);
    }

    m_operator = op;
    m_waitingForOperand = true;
    m_justCalculated = false;
}

void CalculatorEngine::calculate()
{
    if (m_hasError) return;
    if (m_operator.isEmpty()) {
        setExpression(m_displayText + " =");
        return;
    }

    double current = m_displayText.toDouble();
    double result = applyOperator(m_operand, current, m_operator);

    QString expr = m_expressionText;
    // Build full expression for history
    QString histEntry = expr + " " + m_displayText + " = ";

    if (std::isnan(result) || std::isinf(result)) {
        setDisplay("Error");
        setExpression("");
        m_hasError = true;
        emit hasErrorChanged();
        return;
    }

    // Format result nicely
    QString formatted;
    if (result == static_cast<long long>(result) && std::abs(result) < 1e15) {
        formatted = QString::number(static_cast<long long>(result));
    } else {
        formatted = QString::number(result, 'g', 12);
    }

    histEntry += formatted;
    m_history.prepend(histEntry);
    if (m_history.size() > 20) m_history.removeLast();
    emit historyChanged();

    setDisplay(formatted);
    setExpression(expr + " " + m_displayText + " =");
    m_operand = result;
    m_operator = "";
    m_waitingForOperand = false;
    m_justCalculated = true;

    emit animateResult();
}

void CalculatorEngine::clear()
{
    setDisplay("0");
    m_waitingForOperand = false;
    m_justCalculated = false;
    if (m_hasError) {
        m_hasError = false;
        emit hasErrorChanged();
        setExpression("");
        m_operator = "";
    }
}

void CalculatorEngine::clearAll()
{
    setDisplay("0");
    setExpression("");
    m_operand = 0.0;
    m_operator = "";
    m_waitingForOperand = false;
    m_justCalculated = false;
    if (m_hasError) {
        m_hasError = false;
        emit hasErrorChanged();
    }
}

void CalculatorEngine::backspace()
{
    if (m_hasError || m_justCalculated) { clearAll(); return; }
    if (m_displayText.length() <= 1 || m_displayText == "-0") {
        setDisplay("0");
    } else {
        setDisplay(m_displayText.left(m_displayText.length() - 1));
    }
}

void CalculatorEngine::toggleSign()
{
    if (m_hasError) return;
    double val = m_displayText.toDouble();
    val = -val;
    QString formatted;
    if (val == static_cast<long long>(val) && std::abs(val) < 1e15) {
        formatted = QString::number(static_cast<long long>(val));
    } else {
        formatted = QString::number(val, 'g', 12);
    }
    setDisplay(formatted);
}

void CalculatorEngine::percentage()
{
    if (m_hasError) return;
    double val = m_displayText.toDouble();
    val = val / 100.0;
    QString formatted = QString::number(val, 'g', 12);
    setDisplay(formatted);
}

void CalculatorEngine::inputSpecial(const QString &func)
{
    if (m_hasError) return;
    double val = m_displayText.toDouble();
    double result = 0.0;

    if (func == "sqrt") {
        if (val < 0) { setDisplay("Error"); m_hasError = true; emit hasErrorChanged(); return; }
        result = std::sqrt(val);
        setExpression("√(" + m_displayText + ")");
    } else if (func == "sq") {
        result = val * val;
        setExpression("sqr(" + m_displayText + ")");
    } else if (func == "inv") {
        if (val == 0) { setDisplay("Error"); m_hasError = true; emit hasErrorChanged(); return; }
        result = 1.0 / val;
        setExpression("1/(" + m_displayText + ")");
    }

    QString formatted;
    if (result == static_cast<long long>(result) && std::abs(result) < 1e15) {
        formatted = QString::number(static_cast<long long>(result));
    } else {
        formatted = QString::number(result, 'g', 12);
    }
    setDisplay(formatted);
    m_justCalculated = true;
    emit animateResult();
}

double CalculatorEngine::applyOperator(double a, double b, const QString &op)
{
    if (op == "+") return a + b;
    if (op == "−") return a - b;
    if (op == "×") return a * b;
    if (op == "÷") {
        if (b == 0) return std::numeric_limits<double>::quiet_NaN();
        return a / b;
    }
    return b;
}

bool CalculatorEngine::isOperator(const QString &s)
{
    return s == "+" || s == "−" || s == "×" || s == "÷";
}
