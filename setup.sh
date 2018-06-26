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
export GNOME_ACCESSIBILITY=1
export QT_ACCESSIBILITY=1
export QT_LINUX_ACCESSIBILITY_ALWAYS_ON=1

exec ratpoison' > $HOME/.xinitrc
}

install_default_programs()
{
programList=""
for i in leafpad lxterminal pcmanfm seamonkey audacious qalculate-gtk-nognome ; do
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
"audacious")
musicPlayer="${musicPlayer/audacious/audtool}"
add_alias "alias music_player_previous_track exec ${musicPlayer} --playlist-reverse && $notify \"\$(${musicPlayer} --current-song)\" # previous track"
add_alias "alias music_player_play exec ${musicPlayer} --playback-play  && $notify \"\$(${musicPlayer} --current-song)\" # play"
add_alias "alias music_player_pause exec ${musicPlayer} --playback-playpause  && $notify \"\$(${musicPlayer} --current-song)\" # pause"
add_alias "alias music_player_stop exec ${musicPlayer} --playback-stop # stop"
add_alias "alias music_player_next_track exec ${musicPlayer} --playlist-advance  && $notify \"\$(${musicPlayer} --current-song)\" # next track"
add_alias "alias music_player_decrease_volume exec ${musicPlayer} --set-volume \$((\$(${musicPlayer} --get-volume) - 10)) # decrease volume"
add_alias "alias music_player_increase_volume exec ${musicPlayer} --set-volume \$((\$(${musicPlayer} --get-volume) + 10)) # increase volume"
;;
"cmus")
add_alias "alias music_player_previous_track exec ${musicPlayer}-remote -r && $notify \"\$(${musicPlayer}-remote -Q | head -n2 | tr \"[:space:]\" \" \" | sed -e 's/^status //' -e 's/ : /: /' -e \"s#file $HOME/##\" -e 's/^music\|media\///i' -e's#/# - #g' -e 's/\([^\/]*\)\.[^.\/]*$/\1/')\" # previous track"
add_alias "alias music_player_play exec ${musicPlayer}-remote -p && $notify \"\$(${musicPlayer}-remote -Q | head -n2 | tr \"[:space:]\" \" \" | sed -e 's/^status //' -e 's/ : /: /' -e \"s#file $HOME/##\" -e 's/^music\|media\///i' -e 's#/# - #g' -e 's/\([^\/]*\)\.[^.\/]*$/\1/')\" # play"
add_alias "alias music_player_pause exec ${musicPlayer}-remote -u && $notify \"\$(${musicPlayer}-remote -Q | head -n2 | tr \"[:space:]\" \" \" | sed -e 's/^status //' -e 's/ : /: /' -e \"s#file $HOME/##\" -e 's/^music\|media\///i' -e 's#/# - #g' -e 's/\([^\/]*\)\.[^.\/]*$/\1/')\" # pause"
add_alias "alias music_player_stop exec ${musicPlayer}-remote -s # stop"
add_alias "alias music_player_next_track exec ${musicPlayer}-remote -n && $notify \"\$(${musicPlayer}-remote -Q | head -n2 | tr \"[:space:]\" \" \" | sed -e 's/^status //' -e 's/ : /: /' -e \"s#file $HOME/##\" -e 's/^music\|media\///i' -e 's#/# - #g' -e 's/\([^\/]*\)\.[^.\/]*$/\1/')\" # next track"
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
add_alias "alias music_player_previous_track exec ${musicPlayer} prev && sleep 0.75 && $notify \"\$(${musicPlayer} current)\" # previous track"
add_alias "alias music_player_play exec ${musicPlayer} play && sleep 0.75 && $notify \"\$(${musicPlayer} current)\" # play"
add_alias "alias music_player_pause exec ${musicPlayer} toggle && sleep 0.75 && $notify \"\$(${musicPlayer} current)\" # pause"
add_alias "alias music_player_stop exec ${musicPlayer} stop # stop"
add_alias "alias music_player_next_track exec ${musicPlayer} next && sleep 0.75 && $notify \"\$(${musicPlayer} current)\" # next track"
add_alias 'alias music_player_decrease_volume exec /usr/bin/xmms2 server config equalizer.preamp $(($(/usr/bin/xmms2 server config equalizer.preamp | tr -Cd "[:digit:]-") - 10)) # decrease volume'
add_alias 'alias music_player_increase_volume exec /usr/bin/xmms2 server config equalizer.preamp $(($(/usr/bin/xmms2 server config equalizer.preamp | tr -Cd "[:digit:]-") + 10)) # increase volume'
esac
if hash gasher &> /dev/null ; then
add_setting bind G exec gasher -M '# Submit currently playing song to GNU Social'
fi
add_setting "bind M-Z music_player_previous_track"
add_setting "bind M-X music_player_play"
add_setting "bind M-C music_player_pause"
add_setting "bind M-V music_player_stop"
add_setting "bind M-B music_player_next_track"
add_setting "bind M-underscore music_player_decrease_volume"
add_setting "bind M-plus music_player_increase_volume"
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
if ! command -v notify-send &> /dev/null ; then
get_input timeOut "How many seconds should notifications stay on screen before disappearing?" $(echo "-5" {6..30})
notify="yad --info --timeout $timeOut --no-buttons --title 'notification' --text"
else
notify="notify-send"
fi
add_setting "# Generated by strychnine (${0##*/}) http://github.com/stormdragon2976/strychnine"$'\n'$'\n'"# Miscellaneous"
add_setting startup_message off
add_setting set winname title
add_setting "set bgcolor #000000"
add_setting "set fgcolor #FFFFFF"
add_setting 'set font -*-terminus-medium-r-normal-*-24-*-*-*-*-*-*-*'
add_setting set waitcursor 1
add_setting banish

# Unbind existing keys that lead to inaccessible things like xterm or keys that user wants to change, or don't make sense for blind users:
add_setting $'\n'"# Unbind section"
add_setting unbind C-A
add_setting unbind A
add_setting unbind C-a
add_setting unbind a
add_setting unbind c
add_setting unbind C-c
add_setting unbind C-f
add_setting unbind F
add_setting unbind r
add_setting unbind C-r
add_setting unbind S
add_setting unbind C-S
add_setting unbind s
add_setting unbind C-s
add_setting unbind C-t
add_setting unbind C-v
add_setting unbind v
add_setting unbind C-w
add_setting unbind C-Down
add_setting unbind Down
add_setting unbind C-exclam
add_setting unbind exclam
add_setting unbind C-Left
add_setting unbind Left
add_setting unbind question
add_setting unbind C-Right
add_setting unbind Right
add_setting unbind C-Up
add_setting unbind Up
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
get_input answer "Bind alt+f2 to run_dialog (does not work with multiple workspaces):" -yes no
if [ "$answer" = "yes" ]; then
add_setting "# Alt+f2 executes the run dialog"
add_setting definekey top M-F2 run_dialog
fi
add_setting "# Alt+tab switches through open windows"
add_setting definekey top M-Tab next
add_setting definekey top M-ISO_Left_Tab prev
if command -v ocrdesktop &> /dev/null ; then
add_setting definekey top Print exec $(command -v ocrdesktop) -d
fi
add_setting bind exclam run_dialog
add_alias alias ratpoison_keybindings exec 'f=$(mktemp);ratpoison -c "help root" > $f && yad --text-info --show-cursor --title "Ratpoison Keybindings" --button "Close:0" --filename "$f";rm "$f"'
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
for i in -audacious cmus moc mopity mpc pianobar xmms2 ; do
if command -v ${i/#-/} &> /dev/null ; then
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
musicPlayer="$(command -v $musicPlayer)"
fi
set_music_keybindings $musicPlayer
# Configure file browser
unset programList
for i in caja nemo nautilus -pcmanfm ; do
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
fileBrowser="$(command -v $fileBrowser)"
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
webBrowser="$(command -v $webBrowser)"
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
if command -v linphonecsh &> /dev/null ; then
add_alias alias terminate_call exec $(command -v linphonecsh) generic terminate '&&' "$notify" '"Call ended."'
add_setting bind C-F1 terminate_call
add_alias alias answer_call exec $(command -v linphonecsh) generic answer'&&'"$notify" '"Answered call from $(command linphonecsh status hook | cut -d = -f2 | cut -d \  -f1)"'
add_setting bind C-F2 answer_call
add_alias alias linphone_hold exec 'if [[ "$('$(command -v linphonecsh)' status hook)" =~ .*muted=no\ rtp.* ]]; then '$(command -v linphonecsh)' generic mute;'"$notify \"Call muted.\""';elif [[ "$('$(command -v linphonecsh)' status hook)" =~ .*muted=yes\ rtp.* ]]; then '$(command -v linphonecsh)' generic unmute;'"$notify \"Call unmuted\""';fi'
add_setting bind C-F3 linphone_hold
add_alias alias get_live_help exec $(command -v linphonecsh) dial sip:stormdragon2976@iptel.org
add_setting bind C-F4 get_live_help 
add_alias alias call_contact exec 'ifs="$IFS";'"IFS=$'\n';"'sipAddress="$(yad --list --title="Ratpoison" --text "Select contact to call:" --radiolist --column "" --column "Name" --column "Sip Address" $('$(command -v linphonecsh)' generic "friend list" | grep -v "^\*\*" | sed -e "s/^name: /FALSE\n/g" -e "s/^address: //g"))";IFS="$ifs";if [ -n "$sipAddress" ]; then sipAddress="$(echo "$sipAddress" | cut -d \| -f3)";linphonecsh dial "$sipAddress"&&'"$notify"' "Calling $sipAddress";fi'
add_setting bind C-F5 call_contact
fi
if command -v linphone &> /dev/null ; then
add_setting bind M-p exec $(command -v linphone)
fi
if command -v skype &> /dev/null ; then
add_setting bind C-F9 exec skype skype:?hangup
add_setting bind C-F10 exec skype skype:?answercall
add_setting bind C-F11 exec skype skype:?ignorecall
add_setting bind C-F12 exec skype skype:
fi
if command -v pidgin &> /dev/null ; then
add_setting bind p exec $(command -v pidgin)
fi
if command -v talking-clock &> /dev/null ; then
add_setting bind M-t exec $(command -v talking-clock) '-c'
fi
add_setting bind c exec /usr/bin/$terminal
add_setting bind C-c exec /usr/bin/$terminal
add_alias 'alias run_dialog exec historyPath="${XDG_CONFIG_HOME:-$HOME/.config}/strychnine";if ! [ -d "$historyPath" ]; then mkdir -p "$historyPath";fi;write_history(){ oldHistory="$(grep -v "$txt" "$historyPath/history" | head -n 49)";echo -e "$txt\n$oldHistory" | sed '"'s/^$//g'"' > "$historyPath/history"; };if [ -f "$historyPath/history" ]; then txt=$(yad --entry --editable --title "Ratpoison" --text "Execute program or enter file" --button "Open:0" --separator "\n" --rest "$historyPath/history");else txt=$(yad --entry --title "Ratpoison" --text "Execute program or enter file" --button "Open:0");fi;if [ -z "$txt" ]; then exit 0;fi;if [[ "$txt" =~ ^ftp://|http://|https://|www.* ]]; then '"$webBrowser"' $txt;write_history;exit 0;fi;if [[ "$txt" =~ ^mailto://.* ]]; then xdg-email $txt;write_history;exit 0;fi;if [[ "$txt" =~ ^man://.* ]]; then eval "${txt/:\/\// }" | yad --text-info --show-cursor --button "Close:0" --title "Ratpoison" -;write_history;exit 0;fi;if command -v "$(echo "$txt" | cut -d " " -f1)" &> /dev/null ; then eval $txt& else (xdg-open $txt || '"$fileBrowser"')&fi;write_history;exit 0'
add_alias 'alias run_in_terminal_dialog exec c="$(yad --entry --title "Ratpoison" --text "Enter command:")" &&' /usr/bin/$terminal -e '$c'
add_setting bind C-exclam run_in_terminal_dialog
add_alias alias set_window_name exec 't="$(yad --entry --title "Ratpoison" --text "Enter window name") && ratpoison -c "title $t"'
add_setting bind C-A set_window_name
add_setting bind A set_window_name
add_alias alias show_date exec "$notify" '"$(date +"%A, %B %d, %Y%n%I:%M%p")"'
add_setting bind C-a show_date
add_setting bind a show_date
add_setting bind C-t show_date
add_setting bind O exec /usr/bin/orca -r '# Restart Orca'
add_alias alias ratpoison_version exec "$notify" '"$(ratpoison -c "version")"'
add_setting bind C-v ratpoison_version
add_setting bind v ratpoison_version
add_alias alias window_menu exec 'ifs="$IFS";IFS=$'"'"\\n"'"';w="$(yad --list --title "Ratpoison" --text "Select Window" --column "Select" $(ratpoison -c "windows"))";IFS="$ifs";ratpoison -c "select ${w:0:1}"'
add_setting bind C-apostrophe window_menu
add_setting bind apostrophe window_menu
add_alias alias run_ratpoison_command exec 'c="$(yad --entry --title "Ratpoison" --text="Enter Ratpoison command:")" && ratpoison -c "$c"'
add_setting bind colon run_ratpoison_command
add_alias alias reload_ratpoison_configuration exec ratpoison -c "\"source $HOME/.ratpoisonrc\"&&$notify \"Ratpoison configuration reloaded\""
add_setting bind C-colon reload_ratpoison_configuration
add_setting bind C-M-r restart
add_setting bind C-M-q quit

# Autostart section
add_setting $'\n'"# Autostart section"
if hash rpws &> /dev/null ; then
get_input workspaces "Select desired number of workspaces:" -1 {2..8}
if [ $workspaces -gt 1 ]; then
add_setting exec /usr/bin/rpws init $workspaces -k
add_alias alias go_to_workspace_one exec rpws 1
add_alias alias go_to_workspace_two exec rpws 2
add_setting bind Up go_to_workspace_one
add_setting bind Left go_to_workspace_two
fi
if [ $workspaces -ge 3 ]; then
add_alias alias go_to_workspace_three exec rpws 3
add_setting bind Down go_to_workspace_three
fi
if [ $workspaces -ge 4 ]; then
add_alias alias go_to_workspace_four exec rpws 4
add_setting bind Right go_to_workspace_four
fi
if [ $workspaces -ge 5 ]; then
add_alias alias go_to_workspace_five exec rpws 5
add_setting bind C-Up go_to_workspace_five
fi
if [ $workspaces -ge 6 ]; then
add_alias alias go_to_workspace_six exec rpws 6
add_setting bind C-Left go_to_workspace_six
fi
if [ $workspaces -ge 7 ]; then
add_alias alias go_to_workspace_seven exec rpws 7
add_setting bind C-Down go_to_workspace_seven
fi
if [ $workspaces -eq 8 ]; then
add_alias alias go_to_workspace_eight exec rpws 8
add_setting bind C-Right go_to_workspace_eight
fi
fi
# Additional startup programs
programList="$(command -v orca) "
get_input brlapi "Do you want to use a braille display with Orca? " yes -no
if [ "$brlapi" = "yes" ]; then
programList="$(command -v xbrlapi)%20-q "
fi
if command -v glipper &> /dev/null ; then
programList="${programList}$(command -v glipper) "
fi
if command -v hubic &> /dev/null ; then
programList="${programList}$(command -v hubic)%20start "
fi
if command -v linphonecsh &> /dev/null ; then
programList="${programList}$(command -v linphonecsh) "
fi
if [ "${fileBrowser##*/}" = "nemo" ]; then
programList="${programList}${fileBrowser}%20-n"
fi
if [ "${fileBrowser##*/}" = "pcmanfm" ]; then
programList="${programList}${fileBrowser}%20--desktop"
fi
echo "Enter any programs you want started automatically separated by spaces (If your program requires a space, type %20):" | fold -s -w $(tput cols)
read -e -i "$programList" programs
if [ -n "$programs" ]; then
for i in $programs ; do
if command -v $(echo "${i##*/}" | sed 's/%20.*//') &> /dev/null ; then
if [ "$i" = "$(command -v linphonecsh)" ]; then
add_setting exec $(command -v linphonecsh) init -c $HOME/.linphonerc
add_setting exec 'while : ; do incomingCall="$('"$(command -v linphonecsh)"' status hook)";if [[ "$incomingCall" =~ ^Incoming\ call.* ]]; then '"$notify"' "$incomingCall";sleep 9.25;fi;sleep .75;done'
else
add_setting exec ${i//\%20/ }
fi
else
echo "$i was not found."
fi
done
fi
add_setting exec 'if [ "$(gsettings get org.gnome.desktop.a11y.applications screen-reader-enabled)" != "true" ]; then gsettings set org.gnome.desktop.a11y.applications screen-reader-enabled true&&' "$notify \"QT5 accessibility enabled. You need to restart ratpoison for the changes to take affect.\""';fi'
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
