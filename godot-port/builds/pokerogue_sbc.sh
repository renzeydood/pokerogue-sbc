#!/usr/bin/env bash
# PORTMASTER: pokerogue_sbc.zip, pokerogue_sbc.sh

APP_ID="pokerogue_sbc"
APP_VERSION="0.0.1"
APP_PACK="${APP_ID}_${APP_VERSION}.pck"
APP_GPTK="${APP_ID}.gptk"

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/mnt/SDCARD/Emus/tg5040/PORTS.pak/PortMaster"
fi

source "$controlfolder/control.txt"
source "$controlfolder/device_info.txt"

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/${APP_ID}/
CONFDIR="$GAMEDIR/conf/"
PACKFILE="$GAMEDIR/${APP_PACK}"

mkdir -p "$CONFDIR"

LOGFILE="$CONFDIR/port_run.log"
exec > >(tee -a "$LOGFILE") 2>&1
echo "==== $(date '+%Y-%m-%d %H:%M:%S') Pokerogue SBC launch ===="
echo "GAMEDIR=$GAMEDIR"
echo "CONFDIR=$CONFDIR"

export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"

cd "$GAMEDIR" || exit 1
echo "PWD=$(pwd)"

if [ ! -f "$PACKFILE" ]; then
  echo "ERROR: Missing main pack: $PACKFILE"
  echo "Directory listing:"
  ls -la
  sleep 4
  exit 1
fi

echo "Main pack present: $PACKFILE"

runtime="frt_3.5.2"

if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    echo "This port requires the latest PortMaster to run." > /dev/tty0
    sleep 5
    exit 1
  fi

  $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${runtime}.squashfs"
fi

godot_dir="$HOME/godot"
godot_file="$controlfolder/libs/${runtime}.squashfs"

$ESUDO mkdir -p "$godot_dir"
$ESUDO umount "$godot_file" || true
$ESUDO mount "$godot_file" "$godot_dir"

PATH="$godot_dir:$PATH"

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "$runtime" -c "./${APP_GPTK}" textinput &

echo "Launching runtime: $runtime"
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" "$runtime" $GODOT_OPTS --main-pack "$PACKFILE"
echo "Runtime exit code: $?"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0