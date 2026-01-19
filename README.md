# Night Ride – Infotainment Core

This repository contains the **core infotainment application** for the
**Night Ride** open-source automotive modernization project.

The application is built with **Qt 6 / QML** and is intended to run on
**embedded Linux systems** using **Wayland**.

It provides the foundation for:
- vehicle HMI rendering
- media and navigation integration
- system UI and display logic

> ⚠️ This is **not a finished consumer product**.
> It is an experimental, engineering-focused project.

---

## 🛠 Build Instructions

It is recommended to install Qt using the **Qt Online Installer (OSS)**:
https://www.qt.io/download-qt-installer-oss

Install **Qt 6.9.3** (or another compatible Qt 6 version).

> ⚠️ If you choose a different Qt version or installation path, you must
> adjust `CMAKE_PREFIX_PATH` accordingly.

Make sure all required Qt components for your chosen version are installed.
If you discover a minimal dependency set or missing packages, please consider
opening an issue or pull request.

### Default Qt path
```text
/home/[username]/Qt
```

---

## 📦 Clone and Build

```bash
git clone https://github.com/NightRideOrg/nr-infotainment-core.git
cd nr-infotainment-core

mkdir build && cd build

cmake .. \
  -DCMAKE_PREFIX_PATH=~/Qt/6.9.3/gcc_64

make -j$(nproc)
```

---

## ▶ Running the Application

```bash
./nightride-infotainment
```

---

## 🪟 Wayland compatibility notes

Most Qt-based applications can be run under Wayland if they support
platform overrides.

### Examples

**pure-maps**
Should be built manually. See:
[https://github.com/rinigus/pure-maps/blob/master/Build.md](https://github.com/rinigus/pure-maps/blob/master/Build.md)

Run under Wayland:

```bash
QT_QPA_PLATFORM=wayland pure-maps
```

**Spotify (Electron-based)**

```bash
spotify --enable-features=UseOzonePlatform --ozone-platform=wayland
```

> Application behavior under Wayland depends on compositor and system setup.

> [!Note]
> This program uses the [IVI Protocol](https://wayland.pages.freedesktop.org/weston/toc/ivi-shell.html) 
> and the [Qt IVI Compositor](https://doc.qt.io/qt-6/qtwaylandcompositor-ivi-compositor-example.html), 
> so compatibility may vary even more depending on the compositor.

---

## 🖼 Background image requirements

* Minimum resolution: **1920×1080**
* Images are cropped while preserving aspect ratio
