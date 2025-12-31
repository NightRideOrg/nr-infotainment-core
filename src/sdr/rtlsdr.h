#ifndef RTLSDR_H
#define RTLSDR_H

#include <QObject>
#include <QProcess>

class RtlSdr : public QObject
{
    Q_OBJECT

public:
    explicit RtlSdr(QObject *parent = nullptr);
    ~RtlSdr();

    void startRadio(double freqMhz);
    void stopRadio();

signals:
    // CHANGED: We now send the frequency (in Hz) along with the JSON
    void rdsDataAvailable(const QString &jsonString, int frequencyHz);

private slots:
    void handleReadyRead();

private:
    QProcess *m_process;
    int m_currentFrequencyHz; // Store the current frequency
};

#endif // RTLSDR_H
