#include "rtlsdr.h"
#include <QDebug>

RtlSdr::RtlSdr(QObject *parent) : QObject(parent), m_currentFrequencyHz(0)
{
    m_process = new QProcess(this);
    connect(m_process, &QProcess::readyReadStandardOutput, this, &RtlSdr::handleReadyRead);
}

RtlSdr::~RtlSdr() { stopRadio(); }

void RtlSdr::startRadio(double freqMhz)
{
    stopRadio();

    // Store frequency as Hz (integer) for the signal later
    m_currentFrequencyHz = static_cast<int>(freqMhz * 1000000);

    QString program = "/bin/bash";
    // Using 171k sample rate for RDS decoding
    // command: rtl_fm -f $freq -s 171k - | tee >(play -t raw -r 171k -e s -b 16 -c 1 -V1 -q -) | redsea -r 171k
    QString command = QString(
                          "rtl_fm -f %1M -s 171k - | "
                          "tee >(play -t raw -r 171k -e s -b 16 -c 1 -V1 -q -) | "
                          "redsea -r 171k"
                          ).arg(freqMhz);

    QStringList arguments;
    arguments << "-c" << command;
    m_process->start(program, arguments);
}

void RtlSdr::stopRadio()
{
    if (m_process->state() != QProcess::NotRunning) {
        m_process->terminate();
        m_process->waitForFinished(1000);
        m_process->kill();
    }
}

void RtlSdr::handleReadyRead()
{
    QByteArray data = m_process->readAllStandardOutput();
    QString text = QString::fromStdString(data.toStdString());

    if (!text.isEmpty()) {
        // Emit data + the frequency we are currently tuned to
        emit rdsDataAvailable(text, m_currentFrequencyHz);
    }
}
