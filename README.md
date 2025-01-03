# 1. VLC BUILD INSTRUCTIONS

## 2. ANDROID

### 2.1. Prerequisites

- Host OS: Ubuntu 20.04 LTS, x86_64 64-bit. 16G

  Github [codespaces](https://github.com/codespaces)-blank image is recommended.
- Android [SDK](https://developer.android.com/studio) latest version.

```bash
  https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
  android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=/sdk/android-sdk-linux/ "build-tools;26.0.1" "platform-tools" "platforms;android-26" 
```

- Android [NDK](https://developer.android.com/ndk/downloads) r21e.

```text
  https://dl.google.com/android/repository/android-ndk-r21e-linux-x86_64.zip
```

- Android Studio latest version.

```text
  Android Studio Ladybug | 2024.2.1 Patch 3
  Build #AI-242.23339.11.2421.12700392, built on November 23, 2024
  Runtime version: 21.0.3+-79915917-b509.11 aarch64
  VM: OpenJDK 64-Bit Server VM by JetBrains s.r.o.
  Toolkit: sun.lwawt.macosx.LWCToolkit
  macOS 15.2
  GC: G1 Young Generation, G1 Concurrent GC, G1 Old Generation
  Memory: 2048M
  Cores: 8
  Metal Rendering is ON
  Registry:
    ide.experimental.ui=true
    i18n.locale=
```

### 2.2. Build On [codespaces](https://github.com/codespaces)-blank image

Github [codespaces](https://github.com/codespaces)-blank image 8Core 32GB RAM 64GB SSD is recommended.

- Open the terminal and switch to root user.

```bash
sudo su
```

- Install the following packages:

```bash
apt update && \
apt-get install --no-install-suggests --no-install-recommends -y \
    openjdk-17-jdk-headless ca-certificates autoconf m4 automake ant autopoint bison \
    flex build-essential libtool libtool-bin patch pkg-config cmake meson \
    git yasm ragel g++ gettext ninja-build \
    wget expect unzip python3 \
    locales libltdl-dev curl nasm \
    apt-get clean -y &&  rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
```

- Install Android SDK and NDK.

```bash
cd / && mkdir sdk && cd sdk && \
ANDROID_NDK_VERSION=21e
ANDROID_NDK_SHA256=ad7ce5467e18d40050dc51b8e7affc3e635c85bd8c59be62de32352328ed467e && \
    wget -q https://dl.google.com/android/repository/android-ndk-r$ANDROID_NDK_VERSION-linux-x86_64.zip && \
    echo $ANDROID_NDK_SHA256 android-ndk-r$ANDROID_NDK_VERSION-linux-x86_64.zip | sha256sum -c && \
    unzip android-ndk-r$ANDROID_NDK_VERSION-linux-x86_64.zip && \
    rm -f android-ndk-r$ANDROID_NDK_VERSION-linux-x86_64.zip && \
    ln -s android-ndk-r$ANDROID_NDK_VERSION android-ndk && \
    mkdir android-sdk-linux && \
    cd android-sdk-linux && \
    mkdir "licenses" && \
    echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "licenses/android-sdk-license" && \
    echo "d56f5187479451eabf01fb78af6dfcb131a6481e" >> "licenses/android-sdk-license" && \
    SDK_TOOLS_FILENAME=commandlinetools-linux-9477386_latest.zip && \
    wget -q https://dl.google.com/android/repository/$SDK_TOOLS_FILENAME && \
    SDK_TOOLS_SHA256=bd1aa17c7ef10066949c88dc6c9c8d536be27f992a1f3b5a584f9bd2ba5646a0 && \
    echo $SDK_TOOLS_SHA256 $SDK_TOOLS_FILENAME | sha256sum -c && \
    unzip $SDK_TOOLS_FILENAME && \
    rm -f $SDK_TOOLS_FILENAME && \
    cd / && \
    cd sdk/android-sdk-linux && \
    cmdline-tools/bin/sdkmanager --sdk_root=/sdk/android-sdk-linux/ "build-tools;26.0.1" "platform-tools" "platforms;android-26"
```

- Export environment variables

```bash
rm -rf  /home/codespace/java/current && ln -s /home/codespace/java/17.0.13-ms/ /home/codespace/java/current
```

```bash
export ANDROID_SDK=/sdk/android-sdk-linux
export ANDROID_NDK=/sdk/android-ndk
export PATH=$ANDROID_SDK/cmdline-tools/tools/bin:$ANDROID_SDK/platform-tools:$PATH
echo "export ANDROID_NDK=${ANDROID_NDK}" >> /etc/profile.d/vlc_env.sh && \
echo "export ANDROID_SDK=${ANDROID_SDK}" >> /etc/profile.d/vlc_env.sh
```

java-17-openjdk-amd64 for arch x86_64

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/profile.d/vlc_env.sh
```

java-17-openjdk-arm64 for arch arm64

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export PATH=$JAVA_HOME/bin:$PATH
echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/profile.d/vlc_env.sh
```

- Config git user name and email

```bash
git config --global user.email "***@***.com"
git config --global user.name  "username"
```

### 2.3. Build with Dockefile

cd root of script_build_vlc

- Create with Dockerfile

```bash
docker build -t vlc_android .
```

On host apple m1 arm64

```bash
docker build -t vlc_android --platform linux/amd64 .
```

- Run the Docker container

```bash
docker run  --name vlc_android  -v /path/to/vlc:/vlc -it vlc_android /bin/bash
```

- Run the Docker container on host apple m1 arm64

```bash
docker run  --name vlc_android  -v /path/to/vlc:/vlc -it --platform linux/amd64 vlc_android /bin/bash
```

- Run the Docker container with hhool/vlc-android image on dockerhub

```bash
docker run  --name vlc_android  -v /path/to/vlc:/vlc \
-e GIT_COMMITTER_NAME="***@***.com" -e GIT_COMMITTER_EMAIL="username" \
-it hhool/vlc_android:v1.0 /bin/bash
```

### 2.4. Clone VLC and build

- Clone the VLC repository

```bash
cd /vlc && git clone https://code.videolan.org/videolan/vlc-android.git && cd vlc-android
```

build success with special commit-id: 5821fab251c06b78241037788f1a3fc86aa8d985

```text
commit 5821fab251c06b78241037788f1a3fc86aa8d985 (HEAD -> master, origin/master, origin/HEAD)
Author: Nicolas Pomepuy <nicolas@videolabs.io>
Date:   Fri Dec 20 10:24:44 2024 +0100

    Display the app settings when runtime permission previously denied
```

- Build VLC

```bash
./buildsystem/compile.sh
```

- Install VLC

```bash
adb install -r VLC/build/outputs/apk/debug/VLC-debug.apk
```

- Run VLC

```bash
adb shell am start -n org.videolan.vlc/org.videolan.vlc.gui.video.VideoPlayerActivity
```

## 3. IOS

## 4. Mac

## 5. Linux(Ubuntu)
