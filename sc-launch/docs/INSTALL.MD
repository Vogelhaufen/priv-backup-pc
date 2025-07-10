# 🚀 Star Citizen Linux Launcher — Installation Guide

Run **Star Citizen** on Linux with NVIDIA GPU optimization and **DLSS v4** support — made simple!

---

## 🛠 Prerequisites

- Star Citizen installed using **lug-helper (wine-edition)**
- A working Star Citizen Wine prefix

---

## 📥 Installation Steps

### 1. Locate Your Wine Prefix

The script expects your `WINEPREFIX` to be:

$HOME/Games/star-citizen


Place the following files **inside your Wine prefix directory** (usually the path above):

---

### 2. Place the `fetch.sh` Script

Copy `fetch.sh` into your Star Citizen Wine prefix directory.

---

### 3. Make `fetch.sh` Executable

```bash
chmod +x fetch.sh

4. Run the Script

./fetch.sh

5. Start the Game

./startgame

📄 What fetch.sh Does

The fetch.sh script downloads the latest essential files and patches directly into your Wine prefix. This ensures your Star Citizen installation is optimized for NVIDIA GPUs with DLSS v4.

    Tip: Run fetch.sh inside your Wine prefix directory to update the correct location.

⚠️ Important Notes

    Requires a POSIX-compliant shell (e.g., bash or sh). Avoid shells like fish.

    The script might request sudo access to load kernel modules or mount libraries.

    For support and more info:

        Mactan Wine Releases

        Star Citizen Linux Quick Start Guide

🔧 Optional: Create a Symbolic Link

If your Wine prefix is not located at:

$HOME/Games/star-citizen

(for example: /home/YourUserName/MyAwesomeSCdir), you can create a symbolic link to make the script work without modifications.

Replace /home/YourUserName/MyAwesomeSCdir with your actual Wine prefix path and run:

ln -s /home/YourUserName/MyAwesomeSCdir $HOME/Games/star-citizen

    This links the expected path $HOME/Games/star-citizen to your real Wine prefix.

Happy gaming! 🎮✨
