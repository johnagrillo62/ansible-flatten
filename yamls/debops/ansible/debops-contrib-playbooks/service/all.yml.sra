(playbook "debops/ansible/debops-contrib-playbooks/service/all.yml"
  (tasks
    (task "Configure APT Cacher NG with AppArmor"
      (import_playbook "apt_cacher_ng.yml"))
    (task "Configure brtfs filesystem"
      (import_playbook "btrfs.yml"))
    (task "Configure DNSmasq with AppArmor"
      (import_playbook "dnsmasq.yml"))
    (task "Configure Firejail service"
      (import_playbook "firejail.yml"))
    (task "Configure Foodsoft application"
      (import_playbook "foodsoft.yml"))
    (task "Configure FUSE service"
      (import_playbook "fuse.yml"))
    (task "Configure HomeAssistant"
      (import_playbook "homeassistant.yml"))
    (task "Configure Kodi application"
      (import_playbook "kodi.yml"))
    (task "Configure snapshot-snapper for btrfs"
      (import_playbook "snapshot_snapper.yml"))
    (task "Configure Tor Relay"
      (import_playbook "tor.yml"))
    (task "Configure X2Go Server"
      (import_playbook "x2go_server.yml"))))
