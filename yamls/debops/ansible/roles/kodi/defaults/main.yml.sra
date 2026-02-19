(playbook "debops/ansible/roles/kodi/defaults/main.yml"
  (kodi__base_packages (list
      "kodi"
      "xorg"
      "xserver-xorg"
      "dbus-x11"
      "xinit"
      "xserver-xorg-legacy"
      "python-dbus"
      "python3-dbus"
      "accountsservice"
      "pulseaudio"
      "libasound2-plugins"
      "alsa-utils"
      "libfftw3-bin"
      "libfftw3-dev"
      "glew-utils"
      "opus-tools"
      "speex"
      (jinja "{{ [\"policykit-1\"]
        if (kodi__polkit_action | d())
        else [] }}")))
  (kodi__deploy_state "present")
  (kodi__user "kodi")
  (kodi__group "kodi")
  (kodi__groups (list
      "cdrom"
      "floppy"
      "audio"
      "video"
      "plugdev"))
  (kodi__home_path (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
                     + \"/\" + kodi__user }}"))
  (kodi__gecos "kodi.org")
  (kodi__shell "/usr/sbin/nologin")
  (kodi__polkit_action "org.freedesktop.login1.*"))
