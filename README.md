
📌 README.md for qbittorrent-protonvpn-docker (Mac Optimized)

# 🛡️ qBittorrent + ProtonVPN (WireGuard) in Docker (macOS)
**Securely run qBittorrent in Docker with ProtonVPN (WireGuard) using Gluetun, with full VPN routing and automatic port forwarding.**  

[![Docker](https://badgen.net/badge/docker/compose/blue)](https://docs.docker.com/compose/)  
[![License: MIT](https://badgen.net/badge/license/MIT/blue)](LICENSE)  

---

## **🔹 Overview**  
This setup ensures **qBittorrent only connects through ProtonVPN (WireGuard)**, preventing leaks and enhancing security. It also includes **automatic port forwarding** for better torrent speeds.  

### **✅ Features**  
✔ **100% VPN Enforced** – No leaks, qBittorrent only runs inside the VPN.  
✔ **Automatic Port Forwarding** – Ensures better speeds and connectivity.  
✔ **Easy Local Web UI** – Access qBittorrent at [`http://localhost:8080`](http://localhost:8080).  
✔ **Runs on Docker** – Fully containerized for easy deployment.  
✔ **Resilient Setup** – Containers auto-restart if anything crashes.  

---

## **📌 Installation Guide (macOS)**
### **1️⃣ Install Docker Desktop for Mac**
Download and install **Docker Desktop** from [here](https://www.docker.com/products/docker-desktop/).  
- Ensure Docker is **running** before proceeding.  

### **2️⃣ Install Docker Compose (If Not Already Installed)**
Docker Compose is bundled with **Docker Desktop** for macOS, but if you need to install it separately:
```
brew install docker-compose
```

3️⃣ Clone the Repository
```

git clone https://github.com/torrentsec/qbittorrent-protonvpn-docker.git
cd qbittorrent-protonvpn-docker
```
4️⃣ Get Your ProtonVPN WireGuard Credentials
	•	Log in to ProtonVPN
	•	Go to WireGuard Configuration → Select a server
	•	Download the WireGuard config file
	•	Extract the following details:
	•	WIREGUARD_ENDPOINT_IP
	•	WIREGUARD_PUBLIC_KEY
	•	WIREGUARD_PRIVATE_KEY
	•	WIREGUARD_ADDRESSES

5️⃣ Edit docker-compose.yml

Open the file in a text editor (nano, vi, or VS Code) and replace <PLACEHOLDER> values:
```
- WIREGUARD_ENDPOINT_IP=<YOUR_WIREGUARD_SERVER_IP>
- WIREGUARD_PUBLIC_KEY=<YOUR_WIREGUARD_PUBLIC_KEY>
- WIREGUARD_PRIVATE_KEY=<YOUR_WIREGUARD_PRIVATE_KEY>  # Keep this secret!
- WIREGUARD_ADDRESSES=<YOUR_WIREGUARD_CLIENT_IP>/24
```
6️⃣ Start the Containers
```
docker-compose up -d
```
🚀 qBittorrent is now running securely through ProtonVPN!

🌍 Accessing qBittorrent Web UI

Once running, open:
📌 http://localhost:8080
(Default username: admin, password: adminadmin)

🔍 Troubleshooting

🛠 Check if VPN is Running
```
docker ps
```
If gluetun isn’t running, restart everything:
```
docker-compose down && docker-compose up -d
```
🛠 Verify qBittorrent is Using VPN
```
docker exec -it qbittorrent sh
curl ifconfig.me
```
✅ If the IP matches ProtonVPN, it’s working.
❌ If it shows your real IP, something is wrong.

🛠 Check Logs for Errors
```
docker logs -f gluetun
```
Look for AUTH_FAILED or connection issues.

📜 License

This project is licensed under the MIT License – see the LICENSE file for details.

🚀 Contributing

Feel free to submit issues, suggestions, or pull requests!

📢 Support & Feedback

If you found this helpful, give it a ⭐ star and share feedback! 😊
