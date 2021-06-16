/*  Ekos Alignment View
 *  Child of AlignView with few additions necessary for Alignment functions

    Copyright (C) 2017 Jasem Mutlaq <mutlaqja@ikarustech.com>

    This application is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.
*/

#include "alignview.h"

#include "ekos_align_debug.h"
#include "kstarsdata.h"
#include "Options.h"
#include "fitsviewer/fitsdata.h"

#include <QPainter>
#include <QtConcurrent>

AlignView::AlignView(QWidget *parent, FITSMode mode, FITSScale filter) : FITSView(parent, mode, filter)
{
}

void AlignView::drawOverlay(QPainter *painter, double scale)
{
    Q_UNUSED(scale);
    painter->setOpacity(0.5);
    FITSView::drawOverlay(painter, getScale());
    painter->setOpacity(1);

    // drawRaAxis checks to see that the pole is valid and in the image.
    drawRaAxis(painter);

    // drawTriangle checks if the points are valid.
    drawTriangle(painter);

    // ditto
    drawStarCircle(painter);
}

bool AlignView::injectWCS(double orientation, double ra, double dec, double pixscale, bool extras)
{
    bool rc = imageData->injectWCS(orientation, ra, dec, pixscale);
    // If file fails to load, then no WCS data
    if (rc == false)
    {
        qCritical(KSTARS_EKOS_ALIGN) << "Error creating WCS file:" << imageData->getLastError();
        emit wcsToggled(false);
        return false;
    }

    if (wcsWatcher.isRunning() == false && imageData->getWCSState() == FITSData::Idle)
    {
        // Load WCS async
        QFuture<bool> future = QtConcurrent::run(imageData.data(), &FITSData::loadWCS, extras);
        wcsWatcher.setFuture(future);
    }

    return true;
}

void AlignView::reset()
{
    correctionFrom = QPointF();
    correctionTo = QPointF();
    correctionAltTo = QPointF();
    markerCrosshair = QPointF();
    celestialPolePoint = QPointF();
    raAxis = QPointF();
    starCircle = QPointF();
    releaseImage();
}

void AlignView::setCorrectionParams(const QPointF &from, const QPointF &to, const QPointF &altTo)
{
    if (imageData.isNull())
        return;

    correctionFrom = from;
    correctionTo = to;
    correctionAltTo = altTo;
    markerCrosshair = to;

    updateFrame();
}

void AlignView::setStarCircle(const QPointF &pixel)
{
    starCircle = pixel;
    updateFrame();
}

void AlignView::drawTriangle(QPainter *painter)
{
    if (correctionFrom.isNull() && correctionTo.isNull() && correctionAltTo.isNull())
        return;

    painter->setRenderHint(QPainter::Antialiasing);
    painter->setBrush(Qt::NoBrush);

    const double scale = getScale();

    // Some of the points may be out of the image.
    painter->setPen(QPen(Qt::magenta, 2));
    painter->drawLine(correctionFrom.x() * scale,
                      correctionFrom.y() * scale,
                      correctionTo.x() * scale,
                      correctionTo.y() * scale);

    painter->setPen(QPen(Qt::yellow, 3));
    painter->drawLine(correctionFrom.x() * scale,
                      correctionFrom.y() * scale,
                      correctionAltTo.x() * scale,
                      correctionAltTo.y() * scale);

    painter->setPen(QPen(Qt::green, 3));
    painter->drawLine(correctionAltTo.x() * scale,
                      correctionAltTo.y() * scale,
                      correctionTo.x() * scale,
                      correctionTo.y() * scale);

    // In limited memory mode, WCS data is not loaded so no Equatorial Gridlines are drawn
    // so we have to at least draw the NCP/SCP locations
    if (Options::limitedResourcesMode() && !celestialPolePoint.isNull()
            && imageData->contains(celestialPolePoint))
    {
        QPen pen;
        pen.setWidth(2);
        pen.setColor(Qt::darkRed);
        painter->setPen(pen);
        double x  = celestialPolePoint.x() * scale;
        double y  = celestialPolePoint.y() * scale;
        double sr = 3 * scale;

        if (KStarsData::Instance()->geo()->lat()->Degrees() > 0)
            painter->drawText(x + sr, y + sr, i18nc("North Celestial Pole", "NCP"));
        else
            painter->drawText(x + sr, y + sr, i18nc("South Celestial Pole", "SCP"));
    }
}


void AlignView::drawStarCircle(QPainter *painter)
{
    if (starCircle.isNull())
        return;

    painter->setRenderHint(QPainter::Antialiasing);
    painter->setBrush(Qt::NoBrush);

    const double scale = getScale();
    QPointF center(starCircle.x() * scale, starCircle.y() * scale);

    // Could get fancy and change from yellow to green when closer to the green line.
    painter->setPen(QPen(Qt::yellow, 1));
    painter->drawEllipse(center, 35.0, 35.0);
}

void AlignView::drawRaAxis(QPainter *painter)
{
    if (raAxis.isNull() || !imageData->contains(raAxis))
        return;

    QPen pen(Qt::green);
    pen.setWidth(2);
    pen.setStyle(Qt::DashLine);
    painter->setPen(pen);
    painter->setBrush(Qt::NoBrush);

    const double scale = getScale();
    const QPointF center(raAxis.x() * scale, raAxis.y() * scale);

    // Big Radius
    const double r = 200 * scale;

    // Small radius
    const double sr = r / 25.0;

    painter->drawEllipse(center, sr, sr);
    painter->drawEllipse(center, r, r);
    pen.setColor(Qt::darkGreen);
    painter->setPen(pen);
    painter->drawText(center.x() + sr, center.y() + sr, i18n("RA Axis"));
}

void AlignView::setRaAxis(const QPointF &value)
{
    raAxis = value;
    updateFrame();
}

void AlignView::setCelestialPole(const QPointF &value)
{
    celestialPolePoint = value;
    updateFrame();
}

void AlignView::setRefreshEnabled(bool enable)
{
    if (enable)
        setCursorMode(crosshairCursor);
    else
        setCursorMode(selectCursor);
}

void AlignView::processMarkerSelection(int x, int y)
{
    Q_UNUSED(x)
    Q_UNUSED(y)
}

void AlignView::holdOnToImage()
{
    keptImagePointer = imageData;
}

void AlignView::releaseImage()
{
    keptImagePointer.reset();
}
