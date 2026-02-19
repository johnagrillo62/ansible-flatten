(playbook "debops/ansible/roles/kmod/defaults/main.yml"
  (kmod__enabled (jinja "{{ True
                   if (kmod__register_modprobe.stat.exists | bool)
                   else False }}"))
  (kmod__base_packages (list))
  (kmod__packages (list))
  (kmod__default_modules (list
      
      (name "blacklist-firewire-thunderbolt")
      (state "config")
      (comment "Protection against Firewire DMA attacks
https://security.stackexchange.com/a/49158/79474
https://github.com/lfit/itpol/blob/master/linux-workstation-security.md#blacklisting-modules
")
      (blacklist (list
          "firewire_sbp2"
          "firewire_ohci"
          "firewire_core"
          "thunderbolt"))))
  (kmod__modules (list))
  (kmod__group_modules (list))
  (kmod__host_modules (list))
  (kmod__dependent_modules (list))
  (kmod__combined_modules (jinja "{{ kmod__default_modules
                            + lookup(\"flattened\", kmod__dependent_modules, wantlist=True)
                            + kmod__modules
                            + kmod__group_modules
                            + kmod__host_modules }}"))
  (kmod__load (list))
  (kmod__group_load (list))
  (kmod__host_load (list))
  (kmod__dependent_load (list))
  (kmod__combined_load (jinja "{{ lookup(\"flattened\", kmod__dependent_load, wantlist=True)
                         + kmod__load
                         + kmod__group_load
                         + kmod__host_load }}"))
  (kmod__python__dependent_packages3 (list))
  (kmod__python__dependent_packages2 (list
      "python-kmodpy")))
