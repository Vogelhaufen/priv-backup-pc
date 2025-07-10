# 🚀 Star Citizen Linux Launcher — Installation Guide

Run **Star Citizen** on Linux with NVIDIA GPU optimization and **DLSS v4** support — made simple!

---

## 🛠 Prerequisites

- Star Citizen installed with **lug-helper (wine-edition)**
- A working Star Citizen Wine prefix
- A Wayland environment
- Optional: a kernel supporting NTSYNC for more performance

---

## 📥 Installation Steps

1. **Locate Your Wine Prefix**

   By default, the launcher expects your Wine prefix at not

   ```
   $HOME/Games/star-citizen
   ```
   When thats not the case create the symlink mentioned at the bottom to make sure the script can work.

2. **Place the `fetch.sh` Script**

   Copy the `fetch.sh` script into your Wine prefix directory.

3. **Make `fetch.sh` Executable**

   ```bash
   chmod +x fetch.sh
   ```

4. **Run the Script**

   ```bash
   ./fetch.sh
   ```

5. **Start the Game**

   ```bash
   ./startgame
   ```

---

## 📄 What `fetch.sh` Does

The `fetch.sh` script downloads the latest files and patches **directly into your Wine prefix**, ensuring optimal NVIDIA GPU and DLSS v4 support.

> **Tip:** Always run `fetch.sh` inside your Wine prefix directory to update the correct location.

---

## ⚠️ Important Notes

- Requires a POSIX-compliant shell (bash or sh). Avoid shells like fish.
- The script may request `sudo` permissions for loading kernel modules or mounting libraries.
- For more info and help:
  - [Mactan Wine Releases](https://github.com/mactan-sc/mactan-sc-wine/releases/)
  - [Star Citizen Linux Quick Start Guide](https://github.com/starcitizen-lug/knowledge-base/wiki/Quick-Start-Guide)

---

## 🔧 Optional: Create a Symbolic Link

If your Wine prefix is **not** located at `$HOME/Games/star-citizen`, e.g.:

```
/home/YourUserName/MyAwesomeSCdir
```

You can create a symbolic link to avoid modifying the script:

```bash
ln -s /home/YourUserName/MyAwesomeSCdir $HOME/Games/star-citizen
```

This command links the expected path to your actual Wine prefix.

---

*Happy gaming! 🎮✨*
=======
