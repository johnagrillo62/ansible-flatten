(playbook "debops/ansible/roles/unattended_upgrades/defaults/main.yml"
  (unattended_upgrades__enabled "True")
  (unattended_upgrades__release "False")
  (unattended_upgrades__base_packages (list
      "unattended-upgrades"))
  (unattended_upgrades__packages (list))
  (unattended_upgrades__periodic (jinja "{{ False
                                   if (ansible_local.apt.suite | d() == \"archive\")
                                   else unattended_upgrades__enabled }}"))
  (unattended_upgrades__periodic_download (jinja "{{ unattended_upgrades__periodic }}"))
  (unattended_upgrades__periodic_autoclean "7")
  (unattended_upgrades__periodic_verbosity "0")
  (unattended_upgrades__origins (list))
  (unattended_upgrades__origins_lookup (list
      (jinja "{{ ansible_distribution + \"_\" + (ansible_distribution_release.split(\"/\")[0]) }}")
      (jinja "{{ ansible_distribution }}")
      "default"))
  (unattended_upgrades__security_origins 
    (Debian (list
        "o=Debian,n=${distro_codename},l=Debian-Security"
        "o=Debian,n=${distro_codename}-security,l=Debian-Security"
        "o=${distro_id},n=${distro_codename}-updates"))
    (Devuan (list
        "o=Devuan,n=${distro_codename}-security,l=Devuan-Security"
        "o=Devuan,n=${distro_codename}-updates"))
    (Ubuntu (list
        "o=Ubuntu,n=${distro_codename},a=${distro_codename}-security"
        "o=Ubuntu,n=${distro_codename},a=${distro_codename}-updates"))
    (default (list
        "o=${distro_id},n=${distro_codename},l=${distro_id}-Security"
        "o=${distro_id},n=${distro_codename}-updates")))
  (unattended_upgrades__release_origins 
    (Debian (list
        "o=${distro_id},n=${distro_codename}"
        "o=${distro_id} Backports,n=${distro_codename}-backports"))
    (Devuan (list
        "o=${distro_id},n=${distro_codename}"
        "o=${distro_id} Backports,n=${distro_codename}-backports"))
    (Ubuntu (list
        "o=Ubuntu,n=${distro_codename},a=${distro_codename}"
        "o=Ubuntu,n=${distro_codename},a=${distro_codename}-backports"))
    (default (list
        "o=${distro_id},n=${distro_codename}"
        "o=${distro_id},n=${distro_codename}-backports")))
  (unattended_upgrades__dependent_origins (list))
  (unattended_upgrades__default_blacklist (list))
  (unattended_upgrades__blacklist (list))
  (unattended_upgrades__group_blacklist (list))
  (unattended_upgrades__host_blacklist (list))
  (unattended_upgrades__dependent_blacklist (list))
  (unattended_upgrades__auto_fix_interrupted_dpkg "True")
  (unattended_upgrades__ignore_app_require_restart "True")
  (unattended_upgrades__minimal_steps "True")
  (unattended_upgrades__install_on_shutdown "False")
  (unattended_upgrades__mail_from "")
  (unattended_upgrades__mail_to (jinja "{{ ansible_local.core.admin_private_email
                                  | d([\"root@\" + ansible_domain]) }}"))
  (unattended_upgrades__mail_only_on_error "True")
  (unattended_upgrades__remove_unused "False")
  (unattended_upgrades__auto_reboot "False")
  (unattended_upgrades__auto_reboot_time (jinja "{{ \"02:30\"
                                            if (ansible_virtualization_role in [\"host\", \"NA\"])
                                            else (\"02:%02d\" | format(55 | random(seed=inventory_hostname, start=40))) }}"))
  (unattended_upgrades__bandwidth_limit ""))
