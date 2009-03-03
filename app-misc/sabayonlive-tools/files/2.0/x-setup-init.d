#!/sbin/runscript
# Copyright 1999-2005 Gentoo Foundation
# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

depend() {
	after mtab
	before hostname
	before xdm
}


start() {

      is_live=$(cat /proc/cmdline | grep cdroot)
      do_redetect=$(cat /proc/cmdline | grep gpudetect)
      if [ -n "$is_live" ]; then
          ebegin "Configuring GPU Hardware Acceleration and Input devices"
          start-stop-daemon --start --background --pidfile /var/run/x-setup.pid --make-pidfile --exec /usr/sbin/x-setup-configuration
          eend 0
      else
          ebegin "Configuring GPU Hardware Acceleration and Input devices for the first time"
          if [ -e /first_time_run ] || [ ! -e /etc/gpu-detector.conf ] || [ -n "$do_redetect" ]; then
              # store config file
              lspci | grep ' VGA ' > /etc/gpu-detector.conf
              /usr/sbin/x-setup-configuration
              eend 0
              return 0
          fi

          lspci_vga=$(lspci | grep ' VGA ')
          if [ "$lspci_vga" != "`cat /etc/gpu-detector.conf`" ] || [ ! -f /etc/X11/xorg.conf ]; then
              if [ -e "/sbin/aiglx-setup" ]; then
                  /sbin/aiglx-setup disable &> /dev/null
              fi
              if [ -e "/sbin/xgl-setup" ]; then
                  /sbin/xgl-setup disable &> /dev/null
              fi
              /usr/sbin/x-setup-configuration &> /dev/null
              lspci | grep ' VGA ' > /etc/gpu-detector.conf
          fi
          eend 0
      fi
}
