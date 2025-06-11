#Why? NTSYNC, Mousepointer fixes, Anti Infinite Loading fixes thanks to Mactan runner, DLSSv4
#Where? https://github.com/mactan-sc/mactan-sc-wine/releases/tag/10.3-git

#dirty without quick. just the dirty

#changeme
GAMEDIREXE="/mnt/m2games/Heroic-N-Lutris/star-citizen-xdd20252nd/drive_c/Program Files/Roberts Space Industries/RSI Launcher/RSI Launcher.exe"
WINEPREFIX=$HOME/scprefix
#end of changme

#show DLSSv4 debug info?
DXVK_NVAPI_SET_NGX_DEBUG_OPTIONS=DLSSIndicator=1024,DLSSGIndicator=2
#

#protonfoo
GAMEID=umu-starcitizen-noLD
#disable EAC
EOS_USE_ANTICHEATCLIENTNULL=1
#patched cuda
LD_LIBRARY_PATH=/tmp/libcuda.patched.so
#DLSSv4
PROTON_ENABLE_NGX_UPDATER=1 DXVK_NVAPI_DRS_SETTINGS=NGX_DLSS_RR_OVERRIDE=on,NGX_DLSS_SR_OVERRIDE=on,NGX_DLSS_FG_OVERRIDE=on,NGX_DLSS_RR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest,NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest 
#prefixfoo
WINEDLLOVERRIDES="dxwebsetup.exe,dotNetFx45_Full_setup.exe,winemenubuilder.exe=d" 

echo -ne $(od -An -tx1 -v /usr/lib/libcuda.so | tr -d '\n' | sed -e 's/00 00 00 f8 ff 00 00 00/00 00 00 f8 ff ff 00 00/g' -e 's/ /\\x/g') > /tmp/libcuda.patched.so &&  tar xfz /tmp/mactan103 --directory=/tmp/ $(wget -O /tmp/mactan103 https://github.com/mactan-sc/mactan-sc-wine/releases/download/10.3-git/wine-tkg-ntsync-git-10.3.r171.ge66405a5040-327-x86_64.tar.gz) && WINEPREFIX=$HOME/scprefix winetricks -q arial tahoma dxvk powershell win11 vcrun2015 && WINEPREFIX=$HOME/scprefix DXVK_NVAPI_SET_NGX_DEBUG_OPTIONS=DLSSIndicator=1024,DLSSGIndicator=2 EOS_USE_ANTICHEATCLIENTNULL=1 LD_LIBRARY_PATH=/tmp/libcuda.patched.so PROTON_ENABLE_NGX_UPDATER=1 DXVK_NVAPI_DRS_SETTINGS=NGX_DLSS_RR_OVERRIDE=on,NGX_DLSS_SR_OVERRIDE=on,NGX_DLSS_FG_OVERRIDE=on,NGX_DLSS_RR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest,NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest /tmp/wine-tkg-ntsync-git-10.3.r171.ge66405a5040-327-x86_64/bin/wine "$GAMEDIREXE" --disable-gpu --in-process-gpu

echo !!!Change SC Launcher Game Dir to $(echo "Z:$(realpath "$HOME/Games/star-citizen/drive_c/Program Files/Roberts Space Industries")" | sed -e 's/\//\\/g')
