strychnine
==========

Accessible widget replacements for ratpoison. Includes run dialog and keyboard shortcuts help.

Released under the terms of the WTFPL license: http://wtfpl.net.


To set up your ~/.ratpoisonrc run
./setup.sh
Follow the prompts and the file will be created for you.
Use the -x or --xinitrc option to have it create your .xinitrc file.
Use the -i or --install option to install the default packages used by strychnine.
not all distro managers are supported yet. If you would like to add yours, let me know.
If you would like notificationsNotifications can be presented in a couple different ways. If strychnine detects libnotify (via the notify-send command) then it will use it to notify you of things. For this to work you need libnotify and notify-osd installed. If you have those and aren't getting notifications, try removing any packages that may interfere with it, such as mate-notification-daemon. 
