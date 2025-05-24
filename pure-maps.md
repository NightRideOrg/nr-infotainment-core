# PureMaps Installation Guide for Debian 12 (English)

This guide provides step-by-step instructions to manually install [PureMaps](https://github.com/rinigus/pure-maps) on **Debian 12** without using Flatpak, including critical fixes and missing dependencies.

---

## 📦 Prerequisites

Install base dependencies:
```bash
sudo apt update
sudo apt install -y git build-essential cmake ninja-build pkg-config \
    qt5-qmake libqt5core5a libqt5dbus5 qtbase5-dev qtdeclarative5-dev \
    python3 python3-pip python3-setuptools \
    libpcre2-dev libasound2-dev libssl-dev \
    libtool automake autoconf libxml2-dev libxslt1-dev \
    libgeoip-dev libgl1-mesa-dev libgles2-mesa-dev \
    libicu-dev libpopt-dev
```

---

## 🧱 Build Dependencies

### 1. Abseil
```bash
git clone https://github.com/abseil/abseil-cpp.git
cd abseil-cpp
git checkout 4447c7562e3bc702ade25105912dce503f0c4010
mkdir build && cd build
cmake -DBUILD_SHARED_LIBS=ON -G Ninja ..
ninja
sudo ninja install
cd ../..
```

### 2. S2Geometry
```bash
git clone https://github.com/google/s2geometry.git
cd s2geometry
git checkout 713f9c27fed3085cc8dcf18a9d664c39227a0c45
mkdir build && cd build
cmake -DBUILD_SHARED_LIBS=ON -DBUILD_PYTHON=OFF -DBUILD_TESTS=OFF -G Ninja ..
ninja
sudo ninja install
cd ../..
```

### 3. Nemodbus
```bash
sudo apt install -y libqt5svg5-dev  # Required dependency
wget https://github.com/sailfishos/nemo-qml-plugin-dbus/archive/refs/tags/2.1.27.tar.gz
tar -xzvf 2.1.27.tar.gz
cd nemo-qml-plugin-dbus-2.1.27
qmake
make
sudo make install
cd ../
```

### 4. Pyotherside
```bash
sudo apt install -y libqt5svg5-dev  # Required dependency
wget https://github.com/thp/pyotherside/archive/1.5.9.tar.gz
tar -xzvf 1.5.9.tar.gz
cd pyotherside-1.5.9
qmake
make
sudo make install
cd ../
```

### 5. Python3-PyXDG
```bash
pip3 install pyxdg
```

### 6. MapLibre GL Native Qt
```bash
git clone https://github.com/maplibre/maplibre-native-qt.git
cd maplibre-native-qt
git checkout d929c783737120787b43417d9ef05da88da75dfd

# 🔥 Initialize submodules
git submodule update --init --recursive

mkdir build && cd build
cmake -DMLN_QT_WITH_WIDGETS=OFF -DMLN_QT_WITH_LOCATION=OFF \
      -DMLN_QT_WITH_INTERNAL_ICU=ON -DMLN_WITH_WERROR=OFF -G Ninja ..

# 🔧 Fix: Disable tests requiring QOpenGLWidget
cd ..
sed -i 's/add_subdirectory(test)/#add_subdirectory(test)/' CMakeLists.txt

# Continue build
cd build
ninja
sudo ninja install
cd ../..
```

### 7. Mapbox GL QML
```bash
sudo apt install -y qtpositioning5-dev  # Required dependency
git clone https://github.com/rinigus/mapbox-gl-qml.git
cd mapbox-gl-qml
git checkout 7cb85afbf26369db3698ff34af84436cb0d897e7
mkdir build && cd build
cmake -DQT_INSTALL_QML=/usr/lib/qml -G Ninja ..
ninja
sudo ninja install
cd ../..
```

### 8. Mimic1 (Text-to-Speech)
```bash
git clone https://github.com/MycroftAI/mimic1.git
cd mimic1
git checkout eba879c6e4ece50ca6de9b4966f2918ed89148bd
./autogen.sh
./configure --with-audio=none
make
sudo make install
cd ../
```

### 9. Libpopt
```bash
wget https://ftp.osuosl.org/pub/rpm/popt/releases/popt-1.x/popt-1.19.tar.gz
tar -xzvf popt-1.19.tar.gz
cd popt-1.19
./configure
make
sudo make install
cd ../
```

### 10. PicoTTS
```bash
git clone https://github.com/ihuguet/picotts.git
cd picotts
git checkout 21089d223e177ba3cb7e385db8613a093dff74b5
cd pico
./autogen.sh
./configure --prefix=/usr
make
sudo make install
cd ../../
```

---

## 🗺️ Build PureMaps

### 1. Install additional dependencies
```bash
sudo apt install -y qttools5-dev gettext qtquickcontrols2-5-dev
```

### 2. Clone and build PureMaps
```bash
git clone https://github.com/rinigus/pure-maps.git
cd pure-maps
git checkout b594d2f5c480686a2b7df15eb565df3c2f51adff

# 🔧 Download API keys file
wget -O tools/apikeys.py https://raw.githubusercontent.com/flathub/io.github.rinigus.PureMaps/master/apikeys.py

# Start build
mkdir build && cd build
cmake -DFLAVOR=kirigami -DAPP_NAME=io.github.rinigus.PureMaps \
      -DUSE_BUNDLED_GPXPY=ON -DMAPMATCHING_CHECK_RUNTIME=OFF \
      -DMAPMATCHING_AVAILABLE=ON -DUSE_BUNDLED_GEOCLUE2=ON ..
make
sudo make install
```

---

## ⚙️ Post-Installation Setup

### Set environment variables
Add to `~/.bashrc`:
```bash
export QT_PLUGIN_PATH=/usr/local/qml
export QML2_IMPORT_PATH=/usr/local/qml
```
Then run:
```bash
source ~/.bashrc
```

### Audio permissions (for TTS)
```bash
sudo usermod -aG audio $USER
```
*Log out and back in for changes to take effect.*

---

## 🚀 Launch PureMaps
```bash
pure-maps
```

---

## 🛠️ Troubleshooting

- **Missing Qt5.15?** Use [KDE Neon Qt5.15 PPA](https://launchpad.net/~kde-frameworks/+archive/ubuntu/qt515)
- **OpenGL errors?** Install `libgl1-mesa-dev` or test with `mesa-utils`
- **Check logs:** `/var/log/syslog` or terminal output
