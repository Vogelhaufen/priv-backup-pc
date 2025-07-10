# Installation Instructions

1. Install the game with lug-helper (wine-edition).

2. If you already have a Star Citizen installation, make sure your WINEPREFIX is:

$HOME/Games/star-citizen


Otherwise, see the instructions below.

3. Place `fetch.sh` inside your Star Citizen Wine prefix directory  
(typically `$HOME/Games/star-citizen`).

4. Make the script executable:

```bash
chmod +x fetch.sh

    Launch the script:

./fetch.sh

    Start the game:

./startgame

IMPORTANT

This script always assumes your WINEPREFIX is located at:

$HOME/Games/star-citizen

If your actual WINE prefix is somewhere else (for example: /home/YourUserName/MyAwesomeSCdir), you need to create a symbolic link so the script can work correctly.
Creating the symbolic link

Run this command in your terminal, replacing /home/YourUserName/MyAwesomeSCdir with the actual path to your WINE prefix:

ln -s /home/YourUserName/MyAwesomeSCdir $HOME/Games/star-citizen

This command creates a symbolic link at $HOME/Games/star-citizen pointing to your real WINE prefix.
Summary

    Verify your actual WINEPREFIX location.

    Create the symbolic link as shown above.

    Run the script as usual.
