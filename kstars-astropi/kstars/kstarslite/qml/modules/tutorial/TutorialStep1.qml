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

RowLayout {
    signal stepFinished()

    visible: step1
    anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        right: parent.right
    }

    Image {
        id: arrow
        source: "../../images/tutorial-arrow-horizontal.png"
    }

    TutorialPane {
        anchors{
            left: arrow.right
            verticalCenter: arrow.verticalCenter
        }

        contentWidth: (parent.width - arrow.width) * 0.75
        title: xi18n("Global Drawer")
        description: xi18n("By swiping from left to right on any page of KStars Lite you can access global drawer")
        onNextClicked: {
            step1 = false
            step2 = true
        }
    }
}
