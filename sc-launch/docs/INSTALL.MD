# 🚀 Star Citizen Linux Launcher — Installation Guide

Run **Star Citizen** on Linux with NVIDIA GPU optimization and **DLSS v4** support — made simple!

---

## 🛠 Prerequisites

- Star Citizen installed using **lug-helper (wine-edition)**
- A working Star Citizen Wine prefix

---

## 📥 Installation Steps

### 1. Verify Wine Prefix Location

The script expects your `WINEPREFIX` here:

$HOME/Games/star-citizen


If your prefix is somewhere else (e.g., `/home/YourUserName/MyAwesomeSCdir`), create a symbolic link (see next step).

---

### 2. Create Symbolic Link (if needed)

Replace `/home/YourUserName/MyAwesomeSCdir` with your actual Wine prefix path and run:

```bash
ln -s /home/YourUserName/MyAwesomeSCdir $HOME/Games/star-citizen

    This links the expected path to your real Wine prefix.

3. Place the fetch.sh Script

Copy fetch.sh into your Star Citizen Wine prefix directory (usually $HOME/Games/star-citizen).
4. Make fetch.sh Executable

chmod +x fetch.sh

5. Run the Script

./fetch.sh

6. Start the Game

./startgame

📄 What fetch.sh Does

The fetch.sh script downloads the latest essential files and patches directly into your Wine prefix. This ensures your Star Citizen installation is optimized for NVIDIA GPUs with DLSS v4.

    Tip: Run fetch.sh inside your Wine prefix directory (typically $HOME/Games/star-citizen) to update the correct location.

⚠️ Important Notes

    Make sure $HOME/Games/star-citizen does NOT already exist as a regular directory before creating the symlink.

    Requires a POSIX-compliant shell (e.g., bash or sh). Avoid shells like fish.

    The script might request sudo access to load kernel modules or mount libraries.

    For support and more info:

        Mactan Wine Releases

        Star Citizen Linux Quick Start Guide
