#pragma once

#include <QObject>
#include <QString>
#include <QUrl>

class FileHandler : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString filePath READ filePath NOTIFY filePathChanged)
    Q_PROPERTY(QString fileName READ fileName NOTIFY fileNameChanged)
    Q_PROPERTY(bool isModified READ isModified WRITE setIsModified NOTIFY isModifiedChanged)
    Q_PROPERTY(int wordCount READ wordCount NOTIFY statsChanged)
    Q_PROPERTY(int charCount READ charCount NOTIFY statsChanged)
    Q_PROPERTY(int lineCount READ lineCount NOTIFY statsChanged)

public:
    explicit FileHandler(QObject *parent = nullptr);

    QString filePath() const;
    QString fileName() const;
    bool isModified() const;
    int wordCount() const;
    int charCount() const;
    int lineCount() const;

    void setIsModified(bool modified);

public slots:
    QString openFile(const QUrl &fileUrl);
    bool saveFile(const QUrl &fileUrl, const QString &content);
    bool saveCurrentFile(const QString &content);
    void updateStats(const QString &content);
    void newFile();

signals:
    void filePathChanged();
    void fileNameChanged();
    void isModifiedChanged();
    void statsChanged();
    void fileOpened(const QString &content);
    void fileSaved();
    void errorOccurred(const QString &message);

private:
    QString cleanUrlPath(const QUrl &url) const;

    QString m_filePath;
    QString m_fileName;
    bool m_isModified;
    int m_wordCount;
    int m_charCount;
    int m_lineCount;
};
