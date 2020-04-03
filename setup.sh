#!/bin/bash

echo "Setting up SSH: enable root login without password"
sshd_config=$(finddir B_SYSTEM_SETTINGS_DIRECTORY)/ssh/sshd_config
sed -i -e 's/#(PermitRootLogin)*/\1 yes/' -e 's/#(PermitEmptyPasswords)*/\1 yes/' "$sshd_config"

echo "Starting SSH daemon"
useradd sshd
/bin/sshd

echo "Mounting Ports volume"
mountvolume Ports

echo "Setting up git"
git config --global user.name "Builder"
git config --global user.email "builder@localhost"

echo "Setting up HaikuPorter"
if [[ ! -d /Ports/haikuporter ]]; then
  git clone https://github.com/haikuports/haikuporter.git /Ports/haikuporter || exit 1
fi
if [[ ! -d /Ports/haikuports ]]; then
  git clone https://github.com/haikuports/haikuports.git /Ports/haikuports || exit 1
fi

userBin=$(finddir B_USER_NONPACKAGED_BIN_DIRECTORY)

ln -s /Ports/haikuporter/haikuporter "$userBin/haikuporter"

portsCfg=$(finddir B_USER_SETTINGS_DIRECTORY)/haikuports.conf

cat << EOF > "$portsCfg"
TREE_PATH="/Ports/haikuports"
PACKAGER="Leorize's builder $(getarch) <builder@localhost>"
ALLOW_UNTESTED="yes"
EOF

if [[ $(getarch) == x86_gcc2 ]]; then
  echo 'SECONDARY_TARGET_ARCHITECTURES="x86"' >> "$portsCfg"
fi

echo "Installing utilities"
baseDir=$(dirname -- "$0")
install -m755 "$baseDir/porter" "$userBin/porter"
