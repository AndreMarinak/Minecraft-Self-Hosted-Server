This guide will help you set up a Minecraft server on an old PC running Ubuntu while managing it remotely via SSH, Docker, and Playit.gg.

🚫 Stopping SSH (If Needed)
Run these commands to disable SSH for security purposes:

sudo systemctl disable ssh
sudo systemctl stop ssh

🔹 1️⃣ Install Ubuntu on OLDPC
Download and install Ubuntu Desktop (not server)
Download Ubuntu: https://ubuntu.com/download/desktop
Installation Guide: https://www.youtube.com/watch?v=lOy9LFNHHH4
🔹 2️⃣ Setup OLDPC (Linux)
Run the following commands on OLDPC after installing Ubuntu.

🔸 Update System
sudo apt update && sudo apt upgrade -y

🔸 Install Required Dependencies
sudo snap install curl
sudo apt install openssh-server -y
sudo apt install docker-compose -y

🔸 Install Playit.gg
curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list
sudo apt update
sudo apt install playit -y

🔸 Install Docker & Enable Non-Root Access
sudo apt install -y python3-distutils
sudo apt install docker-compose -y
sudo usermod -aG docker $USER
newgrp docker

Verify that Docker runs without sudo:
docker ps

If the command runs successfully, Docker is configured correctly.

🔹 3️⃣ Setup Remote Access from HOST (Windows)
On your Windows machine (HOST), follow these steps.

🔸 Connect to OLDPC via SSH
Open PowerShell or Command Prompt.
Run: ssh <username>@<ip_of_oldpc>
Accept the connection by typing yes and pressing Enter.
Enter the password of OLDPC when prompted.
🔹 4️⃣ Prepare Minecraft Server on OLDPC
🔸 Update Firmware (Optional)
sudo fwupdmgr get-upgrades
sudo fwupdmgr update

🔸 Create Server Directories
mkdir -p ~/minecraft-servers/server1
mkdir -p ~/minecraft-servers/server2
mkdir -p ~/minecraft-servers/backups/server1
mkdir -p ~/minecraft-servers/backups/server2
cd ~/minecraft-servers/server1

🔸 Setup Docker for Minecraft Server
nano ~/minecraft-servers/server1/docker-compose.yml
nano ~/minecraft-servers/server1/mc-server.sh
chmod +x ~/minecraft-servers/server1/mc-server.sh
chmod +x docker-compose

🔹 5️⃣ Setup & Run Playit.gg in tmux
🔸 Install tmux
sudo apt update && sudo apt install tmux -y

🔸 Start a New tmux Session for Playit
tmux new -s playit

🔸 Run Playit.gg Inside tmux
playit

Open the Playit.gg link in the terminal and log in or create an account.

🔸 Detach from tmux (Keep Playit Running)
Press Ctrl + B, then D
This will detach from tmux while keeping Playit running in the background.

🔸 Reattach to tmux (Check Playit Status)
tmux attach -t playit

🔸 Kill tmux Session (Stop Playit)
tmux kill-session -t playit

🔹 6️⃣ Running the Minecraft Server
Navigate to the Minecraft server directory:
cd ~/minecraft-servers/server1

Start the Minecraft server:
./mc-server.sh

View available commands:
./commands

🔹 7️⃣ Restoring a Backup
To restore a previous backup:
tar -xzf $HOME/minecraft-servers/backups/server1/backup-YYYY-MM-DD-HHMM-SIZE.tar.gz -C $HOME/minecraft-servers/server1/

❌ Stopping SSH Access (If Needed)
To disable SSH access for security reasons:
sudo systemctl disable ssh
sudo systemctl stop ssh

🎮 Enjoy Your Remote Minecraft Server!
With Docker, tmux, and Playit.gg, your Minecraft server will run smoothly and be accessible remotely! 🚀
