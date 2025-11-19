import QtQuick 2.0
import calamares.slideshow 1.0

Slideshow {
    Slide {
        title: qsTr("Welcome to Arch Calam")
        text: qsTr("A clean Arch-based live environment with Calamares inspired by EndeavourOS without branding.")
    }
    Slide {
        title: qsTr("Repair toolkit")
        text: qsTr("GParted, TestDisk, SMART tools, and other utilities are available for recovery.")
    }
    Slide {
        title: qsTr("Choose ext4 or Btrfs")
        text: qsTr("Calamares offers guided or manual partitioning with ext4 and Btrfs options.")
    }
}
