import QtQuick 2.15

Rectangle {
    id: root
    color: "#172a3a"

    function onActivate() {}
    function onLeave() {}

    Column {
        anchors.centerIn: parent
        spacing: 18

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Installing Arch Linux")
            color: "white"
            font.pixelSize: 34
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("The installer is configuring KDE Plasma and your selected filesystem.")
            color: "#b8d9ea"
            font.pixelSize: 18
        }
    }
}
