#!/bin/bash

# Configures .ratpoisonrc.
# Written by Storm Dragon
# Released under the therms of the unlicense http://unlicense.org

# Global Variables
false=1
true=0
xdgPath="${XDG_CONFIG_HOME:-$HOME/.config}"

# Get user input args are return variable, question, options
get_input()
{
# Variable names are long, cause I want absolutely no name conflicts.
local __get_input_input=$1
shift
local __get_input_question="$1"
shift
local __get_input_answer=""
local __get_input_i=""
local __get_input_continue=false
for __get_input_i in $@; do
if [ "${__get_input_i:0:1}" = "-" ]; then
local __get_input_default="${__get_input_i:1}"
fi
done
while [ $__get_input_continue = false ]; do
echo -n "$__get_input_question (${@/#-/}) "
if [ -n "$__get_input_default" ]; then
read -e -i "$__get_input_default" __get_input_answer
else
read -e __get_input_answer
fi
for __get_input_i in $@; do
if [ "$__get_input_answer" = "${__get_input_i/#-/}" ]; then
__get_input_continue=true
break
fi
done
done
eval $__get_input_input="'$__get_input_answer'"
}

write_xinitrc()
{
if [ -f "$HOME/.xinitrc" ]; then
get_input continue "This will overwrite your existing $HOME/.xinitrc file. Do you want to continue?" yes no
if [ "$continue" = "no" ]; then
exit 0
fi
fi
echo '#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi
export GTK_MODULES=gail:atk-bridge

exec ratpoison' > $HOME/.xinitrc
}

install_default_programs()
{
programList=""
for i in lxterminal pcmanfm seamonkey xmms2 ; do
if ! hash $i &> /dev/null ; then
programList="${programList}$i "
fi
done
# Get install command for packages
# I'm not sure how to do all of these, so if yours is missing please add it
if hash pacman &> /dev/null ; then
installCommand="pacman -S"
fi
if hash apt-get &> /dev/null ; then
installCommand="apt-get install"
fi
sudo $installCommand $programList
}

add_alias()
{
if [ -z "$rpAlias" ]; then
rpAlias="$@"
else
rpAlias="${rpAlias}"$'\n'"$@"
fi
}

add_setting()
{
if [ -z "$rc" ]; then
rc="$@"
else
rc="${rc}"$'\n'"$@"
fi
}

# Add music keybindings:
set_music_keybindings()
{
add_setting "# Music player bindings:"
case "${1##*/}" in
"cmus")
add_alias "alias music_player_previous_track exec ${musicPlayer}-remote -r # previous track"
add_alias "alias music_player_play exec ${musicPlayer}-remote -p # play"
add_alias "alias music_player_pause exec ${musicPlayer}-remote -u # pause"
add_alias "alias music_player_stop exec ${musicPlayer}-remote -s # stop"
add_alias "alias music_player_next_track exec ${musicPlayer}-remote -n # next track"
add_alias "alias music_player_decrease_volume exec ${musicPlayer}-remote -v -10% # decrease volume"
add_alias "alias music_player_increase_volume exec ${musicPlayer}-remote -v +10% # increase volume"
;;
"moc")
add_alias "alias music_player_previous_track exec ${musicPlayer} -r # previous track"
add_alias "alias music_player_play exec ${musicPlayer} -p # play"
add_alias "alias music_player_pause exec ${musicPlayer} -G # pause"
add_alias "alias music_player_stop exec ${musicPlayer} -s # stop"
add_alias "alias music_player_next_track exec ${musicPlayer} -f # next track"
add_alias "alias music_player_decrease_volume exec ${musicPlayer} -v -10 # decrease volume"
add_alias "alias music_player_increase_volume exec ${musicPlayer} -v +10 # increase volume"
;;
"mpc")
add_alias "alias music_player_previous_track exec ${musicPlayer} -q prev # previous track"
add_alias "alias music_player_play exec ${musicPlayer} -q play # play"
add_alias "alias music_player_pause exec ${musicPlayer} -q pause # pause"
add_alias "alias music_player_stop exec ${musicPlayer} -q stop # stop"
add_alias "alias music_player_next_track exec ${musicPlayer} -q next # next track"
add_alias "alias music_player_decrease_volume exec ${musicPlayer} -q volume -10 # decrease volume"
add_alias "alias music_player_increase_volume exec ${musicPlayer} -q volume +10 # increase volume"
;;
"pianobar")
add_setting "# Pianobar requires a fifo file for its keybindings to work"'\n'"# To create this file, do the following:"'$\n'"# mkfifo $xdgPath/pianobar/ctl"
add_setting "# There is no previous track binding for Pianobar"
add_alias "alias music_player_play exec echo -n 'P' > $xdgPath/pianobar/ctl # play"
add_alias "alias music_player_pause exec echo -n 'p' > $xdgPath/pianobar/ctl # pause"
add_alias "alias music_player_stop exec echo -n 'S' > $xdgPath/pianobar/ctl # stop"
add_alias "alias music_player_next_track exec echo -n 'n' > $xdgPath/pianobar/ctl # next track"
add_alias "alias music_player_decrease_volume exec echo -n '(' > $xdgPath/pianobar/ctl # decrease volume"
add_alias "alias music_player_increase_volume exec echo -n ')' > $xdgPath/pianobar/ctl # increase volume"
;;
"xmms2")
# Insure volume keys will work:
${musicPlayer} server config effect.order.0 equalizer
${musicPlayer} server config equalizer.enabled 1
add_alias "alias music_player_previous_track exec ${musicPlayer} prev && sleep 0.75 && zenity --info --timeout $timeOut --title 'Ratpoison' --text \"\$(${musicPlayer} current)\" # previous track"
add_alias "alias music_player_play exec ${musicPlayer} play && sleep 0.75 && zenity --info --timeout $timeOut --title 'Ratpoison' --text \"\$(${musicPlayer} current)\" # play"
add_alias "alias music_player_pause exec ${musicPlayer} toggle && sleep 0.75 && zenity --info --timeout $timeOut --title 'Ratpoison' --text \"$(${musicPlayer} current)\" # pause"
add_alias "alias music_player_stop exec ${musicPlayer} stop # stop"
add_alias "alias music_player_next_track exec ${musicPlayer} next && sleep 0.75 && zenity --info --timeout $timeOut --title 'Ratpoison' --text \"\$(${musicPlayer} current)\" # next track"
add_alias "alias music_player_decrease_volume exec /usr/bin/xmms2 server config equalizer.preamp $(($(/usr/bin/xmms2 server config equalizer.preamp | tr -Cd "[:digit:]-") - 10)) # decrease volume'
add_alias "alias music_player_increase_volume exec /usr/bin/xmms2 server config equalizer.preamp $(($(/usr/bin/xmms2 server config equalizer.preamp | tr -Cd "[:digit:]-") + 10)) # increase volume'
esac
if hash gasher &> /dev/null ; then
add_setting bind G exec gasher -M '# Submit currently playing song to GNU Social'
fi
add_setting "bind M-z music_player_previous_track"
add_setting "bind M-x music_player_play"
add_setting "bind M-c music_player_pause"
add_setting "bind M-v music_player_stop"
add_setting "bind M-b music_player_next_track"
add_setting "bind M-minus music_player_decrease_volume"
add_setting "bind M-equals music_player_increase_volume"
}

# Install default programs if requested
if [[ "$1" = "-i" || "$1" = "--install" ]]; then
install_default_programs
exit 0
fi
# Create .xinitrc file if requested
if [[ "$1" = "-x" || "$1" = "--xinitrc" ]]; then
write_xinitrc
exit 0
fi
# Make sure rc variable is empty
unset rc
# Set  path for helper scripts.
path="$(readlink -f $0)"
path="${path%/*}"
get_input timeOut "How many seconds should notifications stay on screen before disappearing?" $(echo "-5" {6..30})
add_setting "# Generated by strychnine (${0##*/}) http://github.com/stormdragon2976/strychnine"$'\n'$'\n'"# Miscellaneous"
add_setting startup_message off
add_setting set winname title
add_setting "set bgcolor #000000"
add_setting "set fgcolor #FFFFFF"
add_setting 'set font -*-terminus-medium-r-normal-*-24-*-*-*-*-*-*-*'
add_setting set waitcursor 1
add_setting banish

# Unbind existing keys that lead to inaccessible things like xterm or keys that user wants to change:
add_setting $'\n'"# Unbind section"
add_setting unbind C-A
add_setting unbind A
add_setting unbind C-a
add_setting unbind a
add_setting unbind c
add_setting unbind C-c
add_setting unbind C-t
add_setting unbind C-v
add_setting unbind v
add_setting unbind C-exclam
add_setting unbind exclam
add_setting unbind question
add_setting unbind C-apostrophe
add_setting unbind apostrophe
add_setting unbind colon
get_input escapeKey "Enter desired escape key:" C-t C-z -C-Escape C-space Super_L Super_R
if [ "$escapeKey" != "C-t" ]; then
add_setting unbind t
fi

# Key binding section
add_setting $'\n'"# Key binding section"
# Key binding section
if [ "$escapeKey" != "C-t" ]; then
add_setting escape $escapeKey
fi
add_setting "# Alt+tab switches through open windows"
add_setting definekey top M-Tab next
add_setting definekey top M-ISO_Left_Tab prev
if hash ocrdesktop &> /dev/null ; then
add_setting definekey top Print exec /usr/bin/ocrdesktop
fi
add_setting bind exclam run_dialog
add_alias alias ratpoison_keybindings exec 'f=$(mktemp);ratpoison -c "help root" > $f && zenity --text-info --title "Ratpoison Keybindings" --cancel-label "Close" --ok-label "Close" --filename "$f";rm "$f"'
add_setting bind question ratpoison_keybindings
# Figure out which terminal emulator to use:
unset programList
for i in gnome-terminal mate-terminal -lxterminal ; do
if hash ${i/#-/} &> /dev/null ; then
if [ -n "$programList" ]; then
programList="$programList $i"
else
programList="$i"
fi
fi
done
if [ -z "$programList" ]; then
die "No terminal emulator found, please install one of gnome-terminal, mate-terminal, or lxterminal."
fi
if [ "$programList" != "${programList// /}" ]; then
get_input terminal "Please select a terminal emulator:" $programList
else
terminal="${programList/#-/}"
fi
# Configure music player
unset programList
for i in cmus moc mopity mpc pianobar -xmms2 ; do
if hash ${i/#-/} &> /dev/null ; then
if [ -n "$programList" ]; then
programList="$programList $i"
else
programList="$i"
fi
fi
done
if [ "$programList" != "${programList// /}" ]; then
get_input musicPlayer "Please select a music player:" $programList
else
musicPlayer="${programList/#-/}"
fi
if [ -n "$musicPlayer" ]; then
musicPlayer="/usr/bin/$musicPlayer"
fi
set_music_keybindings $musicPlayer
# Configure file browser
unset programList
for i in caja nemo -pcmanfm ; do
if hash ${i/#-/} &> /dev/null ; then
if [ -n "$programList" ]; then
programList="$programList $i"
else
programList="$i"
fi
fi
done
if [ "$programList" != "${programList// /}" ]; then
get_input fileBrowser "Please select a file browser:" $programList
else
fileBrowser="${programList/#-/}"
fi
if [ -n "$fileBrowser" ]; then
fileBrowser="/usr/bin/$fileBrowser"
fi
add_setting bind f exec $fileBrowser
# Configure web browser
unset programList
for i in chromium epiphany firefox midori -seamonkey ; do
if hash ${i/#-/} &> /dev/null ; then
if [ -n "$programList" ]; then
programList="$programList $i"
else
programList="$i"
fi
fi
done
if [ "$programList" != "${programList// /}" ]; then
get_input webBrowser "Please select a web browser:" $programList
else
webBrowser="${programList/#-/}"
fi
if [ -n "$webBrowser" ]; then
webBrowser="/usr/bin/$webBrowser"
fi
add_setting bind w exec $webBrowser
add_setting bind W exec $webBrowser '$(ratpoison -c getsel) # Open selected URI in web browser' 
# Configure text editor
unset programList
for i in gedit -leafpad libreoffice mousepad pluma ; do
if hash ${i/#-/} &> /dev/null ; then
if [ -n "$programList" ]; then
programList="$programList $i"
else
programList="$i"
fi
fi
done
if [ "$programList" != "${programList// /}" ]; then
get_input textEditor "Please select a text editor:" $programList
else
textEditor="${programList/#-/}"
fi
if [ -n "$textEditor" ]; then
textEditor="/usr/bin/$textEditor"
fi
add_setting bind e exec $textEditor
if hash gasher &> /dev/null ; then
add_setting bind g exec EDITOR="$textEditor" gasher -p  '# Post to GNU Social with Gasher'
fi
if hash mumble &> /dev/null ; then
add_setting bind m exec /usr/bin/mumble
fi
if hash skype &> /dev/null ; then
add_setting bind C-F1 exec skype skype:?hangup
add_setting bind C-F2 exec skype skype:?answercall
add_setting bind C-F3 exec skype skype:?ignorecall
add_setting bind C-F4 exec skype skype:
fi
add_setting bind c exec /usr/bin/$terminal
add_setting bind C-c exec /usr/bin/$terminal
add_alias 'alias run_dialog exec c="$(zenity --entry --title "Ratpoison" --text "Enter command:")" &&' /usr/bin/$terminal -e '$c'
add_setting bind C-exclam run_dialog
add_alias alias set_window_name exec 't="$(zenity --entry --title "Ratpoison" --text "Enter window name") && ratpoison -c "title $t"'
add_setting bind C-A set_window_name
add_setting bind A set_window_name
add_alias alias show_date exec zenity --info --timeout $timeOut --ok-label '"Close"' --title '"Ratpoison"' --text '"$(date +"%A, %B %d, %Y%n%I:%M%p")"'
add_setting bind C-a show_date
add_setting bind a show_date
add_setting bind C-t show_date
add_setting bind O exec /usr/bin/orca -r '# Restart Orca'
add_alias alias ratpoison_version exec zenity --info --ok-label '"Close"' --timeout $timeOut '--title "Ratpoison" --text "$(ratpoison -c "version")"'
add_setting bind C-v ratpoison_version
add_setting bind v ratpoison_version
add_alias alias window_menu exec 'ifs="$IFS";IFS=$'"'"\\n"'"';w="$(zenity --list --title "Ratpoison" --text "Select Window" --column "Select" $(ratpoison -c "windows"))";IFS="$ifs";ratpoison -c "select ${w:0:1}"'
add_setting bind C-apostrophe window_menu
add_setting bind apostrophe window_menu
add_alias alias run_ratpoison_command exec 'c="$(zenity --entry --title "Ratpoison" --text="Enter Ratpoison command:")" && ratpoison -c "$c"'
add_setting bind colon run_ratpoison_command
add_setting bind C-colon exec ratpoison -c "\"source $HOME/.ratpoisonrc\""

# Autostart section
add_setting $'\n'"# Autostart section"
if hash rpws &> /dev/null ; then
get_input workspaces "Select desired number of workspaces:" {1..3} -4 {5..8}
if [ $workspaces -gt 1 ]; then
add_setting exec /usr/bin/rpws init $workspaces -k
fi
fi
# Additional startup programs
programList="/usr/bin/orca "
if hash glipper &> /dev/null ; then
programList="${programList}/usr/bin/glipper "
fi
echo "Enter any programs you want started automatically separated by spaces:"
read -e -i "$programList" programs
if [ -n "$programs" ]; then
for i in $programs ; do
if hash ${i##*/} &> /dev/null ; then
add_setting exec $i
else
echo "$i was not found."
fi
done
fi
if [ -f "$HOME/.ratpoisonrc" ]; then
get_input continue "$HOME/.ratpoisonrc exists. Over write it?" yes no
if [ "$continue" = "no" ]; then
exit 0
fi
fi
echo "$rc" > $HOME/.ratpoisonrc
echo >> $HOME/.ratpoisonrc
echo "# Alias Section">> $HOME/.ratpoisonrc
echo "$rpAlias" >> $HOME/.ratpoisonrc
exit 0
