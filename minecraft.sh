#!/bin/bash

# FILE VERS. : 1.0 (MINECRAFT)
# FILE CREATED BY BRUYERE MAXIMILIEN
# COLOR VAR.

# ERROR
RED="\e[31m"

# SUCCESS
GREEN="\e[32m"

# IN LOADING 
BLUE="\e[34m"

# CONFIGURATION FILE ABOUT MINECRAFT SERVER
# VERSION : FEDORA 40 (SERVER EDITION)
# DEVICE : RASPBERRY PI 4 MOD. B 4GO RAM 
# WARNING : BE SURE THAT YOU UPDATE THE OS BEFORE STARTING IT
# WARNING : YOU'LL NEED PERMISSIONS TO EXECUTE IT
# WARNING : CHECK YOUR SPACE AND YOUR NETWORK BEFORE RUNNING IT

# ++++++++++++++++++
# CREATING MINECRAFT 
# SERVER
# SPECIFIC USER
# ++++++++++++++++++
#
# CREATING SYSTEM USER 
# FOR SECURITY

MINECRAFTUSER=""

minecraftUser() {
	FLAG=true
	while $FLAG; do
		read -p "Set the minecraft server's hostname (need to be system user) : " NAME
		if id "$NAME" &>/dev/null; then
			echo -e "${RED}[MINECRAFT ERROR] The minecraft server's hostname you've used is already taken"
			echo -e "${RED}[MINECRAFT ERROR] by the system. Please, retry."
			FLAG=true
		else
			echo -e "${BLUE}[MINECRAFT] The minecraft server's hostname you've used is not taken"
			echo -e "${BLUE}[MINECRAFT] Creating system user : $NAME ..."
			sudo useradd -r -s /sbin/nologin $NAME 
			echo -e "${GREEN}[MINECRAFT SUCCESS] System user has been created successfully !\n"
			FLAG=false
			MINECRAFTUSER=$NAME			
		fi
	done 
}

# ++++++++++++
#     JAVA 
# INSTALLATION
# ++++++++++++
#
# DOWNLOAD THE LATEST VERSION TO EXECUTE 
# SUCCESSFULLY THE BUILDTOOLS.JAR

javaConfig() {
	echo -e "${BLUE}[JAVA] Creating Java Environnement...\n"
	echo -e "${BLUE}[JAVA] Creating Java Directory."
	mkdir -p /srv/java
	cd /srv/java
	echo -e "${GREEN}[JAVA SUCCESS] Java Directory has been created !"
	echo -e "${BLUE}[JAVA] Downloading Java SE - Developpement Kit - 22."
	wget https://download.oracle.com/java/22/latest/jdk-22_linux-aarch64_bin.tar.gz || { echo -e "${RED}[JAVA ERROR] Failed to download Java SE - Development Kit - 22."; exit 1;}
	echo -e "${GREEN}[JAVA SUCCESS] Java SE - Developpement Kit - 22 has been downloaded !"
	echo -e "${BLUE}[JAVA] File unzipping in loading."	
	tar -xf jdk-22_linux-aarch64_bin.tar.gz || { echo -e "${RED}[JAVA ERROR] Failed to unzip jdk-22_linux-aarch64_bin.tar.gz."; exit 1;} 
	rm jdk-22_linux-aarch64_bin.tar.gz
	echo -e "${GREEN}[JAVA SUCCESS] File unzipping completed !"
	echo -e "${BLUE}[JAVA] Adding Java Environnement."
	echo "export PATH=$PATH:/srv/java/jdk-22.0.2/bin" >> /etc/profile
	echo "export PATH=$PATH:/srv/java/jdk-22.0.2/bin" >> /etc/environment
	# MAYBE YOU SHOULD USE "SOURCE" COMMAND ON YOUR .BASHRC
	# echo echo "export PATH=$PATH:/srv/java/jdk-22.0.2/bin" >> ~/.bashrc
	# source ~/.bashrc
	source /etc/profile
	echo -e "${GREEN}[JAVA SUCCESS] Java Environnement has been added !"
}

# ++++++++++++
#  BUILDTOOLS
# INSTALLATION
# ++++++++++++
#
# MINECRAFT PACKAGES 
# USED TO SETUP THE MINECRAFT SERVER

buildTools() {
	echo -e "${BLUE}[BUILDTOOLS] Creating Minecraft folder."
	mkdir -p /srv/minecraft
	cd /srv/minecraft
	echo -e "${GREEN}[BUILDTOOLS SUCCESS] Minecraft folder has been created !"
	echo -e "${BLUE}[BUILDTOOLS] Downloading Git"
	echo -e "${GREEN}[BUILDTOOLS SUCCESS] Git has been downloaded !"
	dnf install git -y || { echo -e "${RED}[BUILDTOOLS ERROR] Failed to download git."; exit 1; }
	echo -e "${BLUE}[BUILDTOOLS] Downloading BuildTools.jar."
	wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar || { echo -e "${RED}[BUILDTOOLS ERROR] Failed to download BuildTools.jar."; exit 1; }
	echo -e "${GREEN}[BUILDTOOLS SUCCESS] BuildTools.jar has been downloaded !"
	echo -e "${BLUE}[BUILDTOOLS]"
	java -jar BuildTools.jar || { echo -e "${RED}[BUILDTOOLS ERROR] Failed to execute JAVA COMMAND on BuildToold.jar."; exit 1; }
	echo -e "${GREEN}[BUILDTOOLS SUCCESS]"
	echo -e "${BLUE}[BUILDTOOLS] BuildTools Configuration."
	read -p "Please, set the Maximal Memory - Without M (MB)" Xmx
	read -p "Please, set the Minimal Memory - Without M (MB)" Xms
	cat <<-EOF > /srv/minecraft/start.sh
	#!/bin/bash
	export PATH=$PATH:/srv/java/jdk-22.0.2/bin
	java -Xmx${Xmx}M -Xms${Xms}M -jar spigot.jar nogui
	EOF
	chmod 755 start.sh

	# CHANGE THE SPIGOT VERS. BY YOURS
	# mv spigot-[your_version].jar spigot.jar
	
	mv spigot-1.21.1.jar spigot.jar

	echo -e "${GREEN}[BUILDTOOLS SUCCESS] Configuration completed !"
	echo -e "${BLUE}[BUILDTOOLS] Starting of the Minecraft Server."
	./start.sh
	echo -e "${RED}[BUILDTOOLS ERROR] EULA need to be accepted !"
	echo -e "${BLUE}[BUILDTOOLS] Accepting the EULA"
	sed -i 's/eula=false/eula=true/' /srv/minecraft/eula.txt
	echo -e "${GREEN}[BUILDTOOLS SUCCESS] EULA has been accepted !"
	echo -e "${RED}[BUILDTOOLS] Second Starting of the server"
	echo -e "${RED}[BUILDTOOLS] Please, hold on 1 minute."
	sudo -u $MINECRAFTUSER screen -DmS $MINECRAFTUSER /srv/minecraft/start.sh
	sleep 60
	sudo -u $MINECRAFTUSER screen -S $MINECRAFTUSER -p 0 -X stuff "stop$(printf \\r)"
	echo -e "${BLUE}[BUILDTOOLS] Adding correct permissions."
	chown $MINECRAFTUSER:$MINECRAFTUSER -R /srv/minecraft
	echo -e "${GREEN}[BUILDTOOLS SUCCESS] Correct permissions added successfully !"
}

# ++++++++++++
#    SCREEN
# INSTALLATION
# ++++++++++++
#
# GET A DETACHED TERMINAL
# TO ACCESS TO YOUR MINECRAFT SERVER

screenInstallation() {
	echo -e "${BLUE}[SCREEN] Dowloading screen packages."
	dnf install screen -y || { echo -e "${RED}[SCREEN ERROR] Failed to download screen packages."; exit 1;}
	echo -e "${GREEN}[SCREEN SUCCESS] Screen has been downloaded !"

	echo -e "${GREEN}[GUIDE SCREEN] Basic Commands :"
	echo -e "${GREEN}[GUIDE SCREEN]"
	echo -e "${GREEN}[GUIDE SCREEN] screen -ls | List the diff. screen's names"
	echo -e "${GREEN}[GUIDE SCREEN] screen -r [screen's name] | Join the terminal"
	echo -e "${GREEN}[GUIDE SCREEN]"
	echo -e "${GREEN}[GUIDE SCREEN] --------------------------------------------------"
	echo -e "${GREEN}[GUIDE SCREEN]"
	echo -e "${GREEN}[GUIDE SCREEN] CTRL + A --> K | Kill the session."
	echo -e "${GREEN}[GUIDE SCREEN] CTRL + A --> X | Stop the active terminal"
	echo -e "${GREEN}[GUIDE SCREEN]\n"
}

# ++++++++
# COMMANDS
# CREATION
# ++++++++
#
# CREATING CUSTOM COMMANDS TO ACCESS
# EASILY TO YOUR MINECRAFT SERVER

commands() {

	echo -e "${BLUE}[COMMANDS] Creating commands..."

	cat <<-EOF > /usr/bin/joinTerminal
	#!/bin/bash
	session_name=\$(sudo -u $MINECRAFTUSER screen -ls | grep -o '[0-9]*\.$MINECRAFTUSER' | awk -F. '{print \$1}')
	if [ -n "\$session_name" ]; then
		sudo -u $MINECRAFTUSER screen -r \$session_name
	else
		echo "No Minecraft screen session found."
	fi
	EOF

	cat <<-EOF > /usr/bin/stopTerminal
	#!/bin/bash
	sudo -u $MINECRAFTUSER bash -c "screen -S minecraft -p 0 -X stuff \"stop$(printf \\r)\""	
	EOF

	chmod +x /usr/bin/joinTerminal
	chmod +x /usr/bin/stopTerminal

	echo -e "${GREEN}[COMMANDS] Commands have been created !"
}

# +++++++++
# MINECRAFT 
#  SERVICE
# +++++++++
#
# CREATING MINECRAFT SERVICE TO START
# SERVER WHEN THE RASPBERRY IS RESTARTING

minecraftService() {
	cat <<-EOF > /etc/systemd/system/minecraft.service
	[Unit]
	Description=Minecraft Server.
	After=network-online.target
	Wants=network-online.target
	
	[Service]
	User=$MINECRAFTUSER
	WorkingDirectory=/srv/minecraft
	ExecStart=bash -c "screen -DmS $MINECRAFTUSER /srv/minecraft/start.sh"
	ExecStop=/usr/bin/stopTerminal
	Restart=on-abnormal
	Type=simple

	[Install]
	WantedBy=multi-user.target
	EOF

	# WARNING : SELINUX COULD BLOCK THIS SERVICE
	# IF SOMETHING HAPPENS, LOOK AT THIS.

	chown $MINECRAFTUSER:$MINECRAFTUSER -R /srv/minecraft
	sudo usermod -aG screen $MINECRAFTUSER
	echo "minecraft ALL=(ALL) NOPASSWD: /usr/bin/screen" | sudo tee -a /etc/sudoers.d/minecraft
	chmod 755 /etc/systemd/system/minecraft.service
	systemctl daemon-reload
	systemctl enable minecraft.service
	systemctl start minecraft.service
}
# +++++++++++++
# MAIN FUNCTION
# +++++++++++++

main() {

	# MINECRAFT SERVER
	minecraftUser 
	javaConfig 
	screenInstallation 
	buildTools 
	minecraftService
	commands 

	# DNS 
	# ...

	# WARNING : To use DNS properties, you must open your ports on your router !
	# WARNING : To use DNS properties, you must get DOMAIN NAME !
}

main
