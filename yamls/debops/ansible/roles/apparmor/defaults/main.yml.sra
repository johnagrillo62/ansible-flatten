(playbook "debops/ansible/roles/apparmor/defaults/main.yml"
  (apparmor__base_packages (list
      "apparmor"
      "apparmor-utils"
      "apparmor-profiles"
      "apparmor-profiles-extra"))
  (apparmor__packages (list))
  (apparmor__enabled (jinja "{{ ansible_local.apparmor.enabled
                       | d(False
                           if (ansible_distribution_release in [\"stretch\"] or
                               (ansible_virtualization_role | d(\"\") == \"guest\"
                                and
                                ansible_virtualization_type | d(\"\") in
                                  [\"container\"]))
                           else True) }}"))
  (apparmor__manage_grub (jinja "{{ ansible_local.apparmor.grub_enabled
                           | d(True
                               if (apparmor__enabled | d(False) | bool and
                                   ansible_distribution_release in [\"stretch\"])
                               else False) }}"))
  (apparmor__kernel_parameters (list
      "apparmor=1"
      "security=apparmor"))
  (apparmor__default_profiles (list))
  (apparmor__profiles (list))
  (apparmor__group_profiles (list))
  (apparmor__host_profiles (list))
  (apparmor__dependent_profiles (list))
  (apparmor__combined_profiles (jinja "{{ apparmor__default_profiles
                                 + apparmor__profiles
                                 + apparmor__group_profiles
                                 + apparmor__host_profiles
                                 + apparmor__dependent_profiles }}"))
  (apparmor__default_locals (list))
  (apparmor__locals (list))
  (apparmor__group_locals (list))
  (apparmor__host_locals (list))
  (apparmor__dependent_locals (list))
  (apparmor__combined_locals (jinja "{{ apparmor__default_locals
                               + apparmor__locals
                               + apparmor__group_locals
                               + apparmor__host_locals
                               + apparmor__dependent_locals }}"))
  (apparmor__default_tunables (list))
  (apparmor__tunables (list))
  (apparmor__group_tunables (list))
  (apparmor__host_tunables (list))
  (apparmor__dependent_tunables (list))
  (apparmor__combined_tunables (jinja "{{ apparmor__default_tunables
                                 + apparmor__tunables
                                 + apparmor__group_tunables
                                 + apparmor__host_tunables
                                 + apparmor__dependent_tunables }}")))
