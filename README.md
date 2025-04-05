## **This guide will help you set up a Minecraft server on an old PC running Ubuntu while managing it remotely via SSH, Docker, Tailscale, and Playit.gg.**

# ⚠️ Precautions & Security Best Practices  
Follow these best practices to keep your server secure:  

🔹 **Use Strong Passwords** – Avoid weak passwords for SSH and remote access. Use a password manager.  
🔹 **Keep Your IP Private** – Never share your public/private IP online.  
🔹 **Connect to Trusted Networks** – Avoid public WiFi. Use a VPN if necessary.  

---





# 🔹 1️⃣ Install Ubuntu on OLDPC  
Download and install Ubuntu Desktop (not server)  
Download Ubuntu: https://ubuntu.com/download/desktop  
Installation Guide: https://www.youtube.com/watch?v=lOy9LFNHHH4  
Connect WIFI!!!
# 🔹 2️⃣ Setup OLDPC (Linux)  
Run the following commands on OLDPC after installing Ubuntu.  

🔸 Update System  
```
sudo apt update && sudo apt upgrade -y
```

🔸 Install Required Dependencies  
```
sudo snap install curl  
sudo apt install openssh-server -y  
sudo apt install docker-compose -y
```

🔸 Install Playit.gg  
```
curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null  
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list  
sudo apt update  
sudo apt install playit -y
```

🔸 Install Docker & Enable Non-Root Access  
```
sudo apt install -y python3-distutils  
sudo apt install docker-compose -y  
sudo usermod -aG docker $USER  
newgrp docker
```

Verify that Docker runs without sudo:  
```
docker ps
```
If the command runs successfully, Docker is configured correctly.  

# 🔹 3️⃣ Setup Remote Access with Tailscale
Tailscale allows you to access your OLDPC remotely, even when it's on a different WiFi network.

🔸 Install Tailscale on OLDPC  
```
curl -fsSL https://tailscale.com/install.sh | sh  
sudo tailscale up
```
After running `tailscale up`, follow the authentication link and log in.

🔸 Install Tailscale on HOST (Windows)  
Download and install Tailscale from: https://tailscale.com/download  

🔸 Connect HOST and OLDPC  
Once installed, sign in and ensure both devices appear on the Tailscale dashboard.
Find the Tailscale IP of OLDPC by running:
```
tailscale ip -4
```
On Windows (HOST), SSH into OLDPC using:
```
ssh <username>@<tailscale_ip_of_oldpc>
```
Now, you can remotely manage OLDPC even when on different networks!

# 🔹 4️⃣ Setup Remote Access from HOST (Windows)  
If you prefer SSH over Tailscale, follow these steps.  

🔸 Connect to OLDPC via SSH  
Open PowerShell or Command Prompt.  
Run:  
```
ssh <username>@<ip_of_oldpc>
```
Accept the connection by typing `yes` and pressing Enter.  
Enter the password of OLDPC when prompted.  

# 🔹 5️⃣ Creating/Editing Configuration Files  
cd to the correct server (cd minecraft-servers/server1)
To configure/create your Minecraft server, you need to edit two key files:  

1. **Open the Docker Compose file:**  
   ```
   nano ~/minecraft-servers/server1/docker-compose.yml
   ```
   🚨You must change the correct docker container name, version, and change the number before the : on the Port line🚨
2. **Open the Minecraft Server script:**  
   ```
   nano ~/minecraft-servers/server1/mc-server.sh
   ```  
   🚨This has 3 "server1" that you much change the server# that fits🚨
### 🔹 **Copy & Paste Instructions**  
- Open each file using the `nano` command.  
- Visit the **GitHub repository** to find the correct file contents.  
- Copy the contents from GitHub and paste them into the terminal using **Ctrl + Shift + V**.  
- Save the file in `nano` by pressing **Ctrl + X**, then **Y**, then **Enter**.  

Now your Minecraft server is properly configured! 🚀


# 🔹 6️⃣ Prepare Minecraft Server on OLDPC  
🔸 Update Firmware (Optional)  
```
sudo fwupdmgr get-upgrades  
sudo fwupdmgr update
```

🔸 Create Server Directories  
```
mkdir -p ~/minecraft-servers/server1  
mkdir -p ~/minecraft-servers/server2  
mkdir -p ~/minecraft-servers/backups/server1  
mkdir -p ~/minecraft-servers/backups/server2  
cd ~/minecraft-servers/server1
```

🔸 Setup Docker for Minecraft Server  
```
nano ~/minecraft-servers/server1/docker-compose.yml  
nano ~/minecraft-servers/server1/mc-server.sh  
chmod +x ~/minecraft-servers/server1/mc-server.sh  
chmod +x docker-compose
```

# 🔹 7️⃣ Setup & Run Playit.gg in tmux  
🔸 Install tmux  
```
sudo apt update && sudo apt install tmux -y
```

🔸 Start a New tmux Session for Playit  
```
tmux new -s playit
```

🔸 Run Playit.gg Inside tmux  
```
playit
```
Open the Playit.gg link in the terminal and log in or create an account. (This will give you a MC server address anyone can join)
Select TCP, then Minecraft Java***

🔸 Detach from tmux (Keep Playit Running)  
Press `Ctrl + B`, then `D`  
This will detach from tmux while keeping Playit running in the background.  

🔸 Reattach to tmux (Check Playit Status)  
```
tmux attach -t playit
```

🔸 Kill tmux Session (Stop Playit)  
```
tmux kill-session -t playit
```

# 🔹 7️⃣ Running the Minecraft Server  
Navigate to the Minecraft server directory:  
```
cd ~/minecraft-servers/server1
```

Start the Minecraft server:  
```
./mc-server.sh
```

View available commands:  
```
./commands
```

Then do:
```
./start
```
🚨NOTE: You may have to do the start command twice to allow world generation. This command is the same as(docker-compose up -d)

For console:
```
./console
```

Run any commands from this list starting with "./"
Most useful ones will be ./start and ./stop to start and stop the server


# 🔹 8️⃣ Automating Backups with Cron Jobs  
Use a **cron job** to automatically back up your Minecraft server data every **Sunday at 3 AM**.

### 🔹 **Setting Up the Cron Job**  
1. Open the crontab editor:  
   ```
   crontab -e
   ```  
2. Add the following line at the bottom:  
   ```
   0 3 * * 0 /bin/bash -c 'BACKUP_DIR="$HOME/minecraft-servers/backups/server1/weeklybu"; mkdir -p "$BACKUP_DIR"; SIZE=$(du -sh "$HOME/minecraft-servers/server1/data" | cut -f1); TIMESTAMP="$(date +\%F-\%H%M)"; BACKUP_FILE="$BACKUP_DIR/backup-$TIMESTAMP-${SIZE}.tar.gz"; tar -czf "$BACKUP_FILE" -C "$HOME/minecraft-servers/server2" data'
   ```
3.🚨 Replace "server1" with the proper name (server2, server3...) 🚨
4. Save and exit the crontab editor.  

### 🔹 **How It Works**  
- **Runs at 3 AM every Sunday** (`0 3 * * 0`)  
- **Creates a backup directory** (`weeklybu`) if it doesn’t exist.  
- **Calculates the size of the server data folder**.  
- **Generates a timestamped backup file**.  
- **Compresses the data folder into a `.tar.gz` backup file**.  

### 🔹 **Verifying the Cron Job**  
Check if your cron job is active:  
```
crontab -l
```

### 🔹 **Manually Running the Backup Script**  
If needed, you can run the backup manually (🚨for server1, change if needed🚨):  
```
/bin/bash -c 'BACKUP_DIR="$HOME/minecraft-servers/backups/server1/weeklybu"; mkdir -p "$BACKUP_DIR"; SIZE=$(du -sh "$HOME/minecraft-servers/server1/data" | cut -f1); TIMESTAMP="$(date +\%F-\%H%M)"; BACKUP_FILE="$BACKUP_DIR/backup-$TIMESTAMP-${SIZE}.tar.gz"; tar -czf "$BACKUP_FILE" -C "$HOME/minecraft-servers/server2" data'
```

Now your Minecraft server data will be **automatically backed up every Sunday at 3 AM**! 🚀



# 🔹 9️⃣ Restoring a Backup  
To restore a previous backup:  
```
tar -xzf $HOME/minecraft-servers/backups/server1/backup-YYYY-MM-DD-HHMM-SIZE.tar.gz -C $HOME/minecraft-servers/server1/
```
*🚨REPLACE "SERVER1" with the correct number you want to backup (IN both places)🚨

# 🚫 Stopping SSH (If Needed)  
Run these commands to disable SSH for security purposes:  
```
sudo systemctl disable ssh  
sudo systemctl stop ssh
```

# ⚠️ Precautions & Security Best Practices  
Follow these best practices to keep your server secure:  

🔹 **Use Strong Passwords** – Avoid weak passwords for SSH and remote access. Use a password manager.  
🔹 **Keep Your IP Private** – Never share your public/private IP online.  
🔹 **Connect to Trusted Networks** – Avoid public WiFi. Use a VPN if necessary.  
🔹 **Enable Firewall & Restrict SSH** – Use `ufw` to block unwanted access:  
  ```
  sudo ufw allow OpenSSH
  sudo ufw enable
  ```
  Disable SSH when not in use:  
  ```
  sudo systemctl stop ssh
  sudo systemctl disable ssh
  ```  
🔹 **Keep Software Updated** – Regularly update your system and dependencies:  
  ```
  sudo apt update && sudo apt upgrade -y
  ```  
🔹 **Use tmux for Remote Sessions** – Prevent losing progress when disconnected:  
  ```
  tmux new -s minecraft
  ```  
🔹 **Limit User Permissions** – Avoid running the server as root. Create a dedicated user:  
  ```
  sudo adduser mcserver
  sudo usermod -aG docker mcserver
  ```  
🔹 **Monitor Server Activity** – Check active users and processes:  
  ```
  who
  w
  top
  ```  
🔹 **Backup Regularly** – Store backups separately and automate with cron jobs.  

By following these precautions, your Minecraft server will stay secure and reliable! 🚀

---
---
---
---
🎮 Enjoy Your Remote Minecraft Server!  
With Docker, Tmux, Tailscale, and Playit.gg, your Minecraft server will run smoothly and be accessible remotely! 🚀

