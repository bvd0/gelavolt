![GelaVolt](readme-icon.png)

# Project GelaVolt

### Join the Development Discord: https://discord.gg/wsWArpAFJK
### Try GelaVolt's web build at: https://gelavolt.io

Welcome to GelaVolt, a fanmade version of Japan's favourite competitive puzzle fighter!

GelaVolt's primary goals are:
- Introduce more people to the game
- Help new players learn and intermediate players improve
- (Eventually) Recreate and improve the online experience using rollback netcode, a more robust lobby and matchmaking system, crossplay and more!


# Example build environment setup
## Linux (Debian 11)
### Install the tools used in these examples:
```sh
sudo apt install -V  git nodejs
```
### Dependencies
Install dependencies for the Kha SDK found at https://github.com/Kode/Kha/wiki/Linux. As of 2022-03-07 these are:
```sh
sudo apt install -V  make g++ libxinerama-dev libxrandr-dev libasound2-dev libxi-dev mesa-common-dev libgl-dev libxcursor-dev libvulkan-dev libudev-dev
```
Install other dependencies:
```sh
sudo apt install -V  libwayland-dev libegl-dev wayland-protocols libxkbcommon-dev
```
(Tested on [debian-live-11.2.0-amd64-standard.iso](https://cdimage.debian.org/cdimage/release/11.2.0-live/amd64/iso-hybrid/))
##

### Get the GelaVolt source code and the [Kha](https://github.com/Kode/Kha) SDK:
Make a new folder and set it as the current working directory (optional):
```sh
mkdir new_folder && cd new_folder
```
```sh
git clone https://github.com/doczi-dominik/gelavolt.git
```
```sh
git clone --recursive https://github.com/Kode/Kha.git
```

### Build
Linux:
```sh
node ./Kha/make.js --from ./gelavolt --to ./gelavolt/build --compile -t linux -g opengl 
```
Windows:
```sh
node ./Kha/make.js --from ./gelavolt --to ./gelavolt/build --compile -t windows -g direct3d11 
```
html5:
```sh
node ./Kha/make.js --from ./gelavolt --to ./gelavolt/build -t html5
```
