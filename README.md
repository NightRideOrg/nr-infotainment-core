## Build Instructions

It is recommended to download the **Qt Online Installer** from:
[https://www.qt.io/download-qt-installer-oss](https://www.qt.io/download-qt-installer-oss)

Install Qt version **6.8.3** (or another version of your choice).

> ⚠️ If you choose a different version or installation path, you must adjust the `CMAKE_PREFIX_PATH` accordingly.

Make sure to **install all required packages for your chosen Qt version**.
If you want, you can try installing the packages one by one to identify which are actually needed.
If you find a minimal set or discover missing dependencies, please consider opening an issue or pull request to improve this documentation.

By default, it is assumed that Qt is installed to:
`/home/[username]/Qt`

### Clone and Build

```bash
git clone https://github.com/MaizeShark/Car_Infotainment/
cd Car_Infotainment
mkdir build && cd build

cmake .. \
  -DCMAKE_PREFIX_PATH=~/Qt/6.8.3/gcc_64

make -j$(nproc)
```

---

## Running the Application

For X11/Wayland compatibility:

```bash
QT_XCB_GL_INTEGRATION=xcb_egl \
QT_WAYLAND_CLIENT_BUFFER_INTEGRATION=xcomposite-egl \
./Car_Infotainment
```

---

## Wayland Compatibility for Other Applications

You can run most Qt-based applications under Wayland if they support platform overrides.
For example:

* **pure-maps**:
  Must be built manually. Follow the instructions at:
  [https://github.com/MaizeShark/pure-maps/blob/Updated-Readme/Build.md](https://github.com/MaizeShark/pure-maps/blob/Updated-Readme/Build.md)

  To run it under Wayland:

  ```bash
  QT_QPA_PLATFORM=wayland pure-maps
  ```

* **Spotify**:
  Spotify (Electron-based) can be run with Wayland support as follows:



  ```bash
  spotify --enable-features=UseOzonePlatform --ozone-platform=wayland
  ```

> Note: Application behavior under Wayland may vary depending on system configuration and compositor support.

---
# Background Image Requirements

* The background image must have a **minimum resolution of 1920×1080 pixels**.
* The image will be **cropped while preserving its aspect ratio**.
