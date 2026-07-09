#include "filehandler.h"
#include <QFile>
#include <QTextStream>
#include <QFileInfo>
#include <QDir>
#include <QDebug>

FileHandler::FileHandler(QObject *parent)
    : QObject(parent)
    , m_filePath("")
    , m_fileName("Untitled")
    , m_isModified(false)
    , m_wordCount(0)
    , m_charCount(0)
    , m_lineCount(1)
{
}

QString FileHandler::filePath() const { return m_filePath; }
QString FileHandler::fileName() const { return m_fileName; }
bool FileHandler::isModified() const { return m_isModified; }
int FileHandler::wordCount() const { return m_wordCount; }
int FileHandler::charCount() const { return m_charCount; }
int FileHandler::lineCount() const { return m_lineCount; }

void FileHandler::setIsModified(bool modified)
{
    if (m_isModified != modified) {
        m_isModified = modified;
        emit isModifiedChanged();
    }
}

void FileHandler::newFile()
{
    m_filePath = "";
    m_fileName = "Untitled";
    m_isModified = false;
    m_wordCount = 0;
    m_charCount = 0;
    m_lineCount = 1;
    emit filePathChanged();
    emit fileNameChanged();
    emit isModifiedChanged();
    emit statsChanged();
}

QString FileHandler::openFile(const QUrl &fileUrl)
{
    QString localPath = cleanUrlPath(fileUrl);
    QFile file(localPath);

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        emit errorOccurred("Could not open file for reading.");
        return "";
    }

    QTextStream in(&file);
    QString content = in.readAll();
    file.close();

    m_filePath = localPath;
    m_fileName = QFileInfo(localPath).fileName();
    m_isModified = false;

    updateStats(content);

    emit filePathChanged();
    emit fileNameChanged();
    emit isModifiedChanged();
    emit fileOpened(content);

    return content;
}

bool FileHandler::saveFile(const QUrl &fileUrl, const QString &content)
{
    QString localPath = cleanUrlPath(fileUrl);
    QFile file(localPath);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        emit errorOccurred("Could not open file for writing.");
        return false;
    }

    QTextStream out(&file);
    out << content;
    file.close();

    m_filePath = localPath;
    m_fileName = QFileInfo(localPath).fileName();
    m_isModified = false;

    updateStats(content);

    emit filePathChanged();
    emit fileNameChanged();
    emit isModifiedChanged();
    emit fileSaved();

    return true;
}

bool FileHandler::saveCurrentFile(const QString &content)
{
    if (m_filePath.isEmpty()) {
        emit errorOccurred("No file path set. Use Save As.");
        return false;
    }
    return saveFile(QUrl::fromLocalFile(m_filePath), content);
}

void FileHandler::updateStats(const QString &content)
{
    m_charCount = content.length();

    // Word count calculation
    m_wordCount = 0;
    bool inWord = false;
    for (const QChar &ch : content) {
        if (ch.isSpace()) {
            inWord = false;
        } else {
            if (!inWord) {
                inWord = true;
                m_wordCount++;
            }
        }
    }

    // Line count calculation
    m_lineCount = content.count('\n') + 1;

    emit statsChanged();
}

QString FileHandler::cleanUrlPath(const QUrl &url) const
{
    if (url.isLocalFile()) {
        return url.toLocalFile();
    }
    // Fallback cleanup for QML Url scheme conversions
    QString path = url.toString();
    if (path.startsWith("file:///")) {
        path = path.mid(8);
    } else if (path.startsWith("file://")) {
        path = path.mid(7);
    }
    return path;
}
