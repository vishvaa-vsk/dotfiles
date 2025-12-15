#!/usr/bin/bash
# A "bulletproof" script to run from Dank Hooks

# --- (1. DEFINE PATHS) ---
USER_HOME="/home/vishvaa"
THEME_SOURCE_DIR="$USER_HOME/Tela-circle-icon-theme-source"
MATUGEN_COLORS="$USER_HOME/.cache/DankMaterialShell/dms-colors.json"
INSTALL_DIR="$USER_HOME/.local/share/icons"
LOG_FILE="/tmp/dms_icon_hook.log"

# --- (2. DEFINE COMMAND PATHS) ---
JQ_BIN="/usr/bin/jq"
BASH_BIN="/usr/bin/bash"
GSETTINGS_BIN="/usr/bin/gsettings"
GREP_BIN="/usr/bin/grep"
PGREP_BIN="/usr/bin/pgrep"
CUT_BIN="/usr/bin/cut"
ID_BIN="/usr/bin/id"

# --- (3. START LOG) ---
echo "--- DMS ICON HOOK ---" > "$LOG_FILE"
echo "Script started at $(date)" >> "$LOG_FILE"

# --- (4. GET COLOR) ---
PRIMARY_HEX=$("$JQ_BIN" -r '.colors.dark.primary | ltrimstr("#")' "$MATUGEN_COLORS")
if [ -z "$PRIMARY_HEX" ]; then
  echo "ERROR: Could not find primary color in $MATUGEN_COLORS" >> "$LOG_FILE"
  exit 1
fi
echo "Found color: $PRIMARY_HEX" >> "$LOG_FILE"

# --- (5. DEFINE THEME NAME) ---
BASE_THEME_NAME="Tela-circle-matugen"
FULL_THEME_NAME="${BASE_THEME_NAME}-${PRIMARY_HEX}"
echo "Full theme name will be: $FULL_THEME_NAME" >> "$LOG_FILE"

# --- (6. RUN INSTALLER) ---
echo "Running Tela installer..." >> "$LOG_FILE"
"$BASH_BIN" "$THEME_SOURCE_DIR/install.sh" -n "$BASE_THEME_NAME" -d "$INSTALL_DIR" "$PRIMARY_HEX" >> "$LOG_FILE" 2>&1

# --- (7. APPLY THEME - THE REAL FIX) ---
echo "Attempting to apply theme..." >> "$LOG_FILE"
USER_NAME="vishvaa"
USER_ID=$("$ID_BIN" -u "$USER_NAME")

# Find the user's D-Bus session address from the running Hyprland process
# We use full paths for ALL commands
HYPR_PID=$("$PGREP_BIN" -u "$USER_NAME" hyprland)
if [ -z "$HYPR_PID" ]; then
    echo "ERROR: Could not find Hyprland PID." >> "$LOG_FILE"
else
    echo "Found Hyprland PID: $HYPR_PID" >> "$LOG_FILE"
    export DBUS_SESSION_BUS_ADDRESS=$("$GREP_BIN" -z DBUS_SESSION_BUS_ADDRESS /proc/$HYPR_PID/environ | "$CUT_BIN" -d= -f2-)
fi

# Check if we found it
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    echo "ERROR: Could not find D-Bus session via Hyprland. Trying fallback." >> "$LOG_FILE"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus"
fi
echo "Using D-Bus: $DBUS_SESSION_BUS_ADDRESS" >> "$LOG_FILE"

# Run gsettings with the correct environment
"$GSETTINGS_BIN" set org.gnome.desktop.interface icon-theme "$FULL_THEME_NAME"

# Check if it worked
CURRENT_THEME=$("$GSETTINGS_BIN" get org.gnome.desktop.interface icon-theme)
echo "gsettings GET reports theme is now: $CURRENT_THEME" >> "$LOG_FILE"
echo "Script finished." >> "$LOG_FILE"
