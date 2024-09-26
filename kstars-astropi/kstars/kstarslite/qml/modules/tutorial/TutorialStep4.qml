// Copyright (C) 2016 Artem Fedoskin <afedoskin3@gmail.com>
/***************************************************************************
*                                                                         *
*   This program is free software; you can redistribute it and/or modify  *
*   it under the terms of the GNU General Public License as published by  *
*   the Free Software Foundation; either version 2 of the License, or     *
*   (at your option) any later version.                                   *
*                                                                         *
***************************************************************************/

import QtQuick 2.7

import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Universal 2.0

import QtQuick.Window 2.2 as Window
import QtQuick.Layouts 1.1

ColumnLayout {
    visible: step4
    spacing: 10
    anchors {
        left: parent.left
        right: parent.right
    }

    TutorialPane {
        anchors.horizontalCenter: parent.horizontalCenter

        contentWidth: parent.width * 0.75
        title: xi18n("Bottom Menu")
        description: xi18n("By tapping on this arrow you can access bottom menu from which you can set time and start time simulation")

        onNextClicked: {
            step4 = false
            step5 = true
        }
    }

    Image {
        source: "../../images/tutorial-arrow-vertical.png"
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
