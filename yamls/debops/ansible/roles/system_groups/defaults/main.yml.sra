(playbook "debops/ansible/roles/system_groups/defaults/main.yml"
  (system_groups__enabled "True")
  (system_groups__sudo_enabled (jinja "{{ True
                                 if (ansible_local.sudo.installed | d() | bool)
                                 else False }}"))
  (system_groups__admins_sudo_nopasswd (jinja "{{ False
                                         if (system_groups__fact_ansible_connection == \"local\")
                                         else True }}"))
  (system_groups__prefix (jinja "{{ ansible_local.system_groups.local_prefix
                           if (ansible_local | d() and ansible_local.system_groups | d() and
                               ansible_local.system_groups.local_prefix is defined)
                           else (\"_\"
                                 if (\"debops_service_ldap\" in group_names or
                                     (ansible_local.ldap.posix_enabled | d() | bool))
                                 else \"\") }}"))
  (system_groups__throttle "8")
  (system_groups__default_list (list
      
      (name (jinja "{{ system_groups__prefix }}") "admins")
      (sudoers_filename "system_groups-admins")
      (sudoers "# This might be required to allow Ansible pipelining connections
Defaults: %" (jinja "{{ system_groups__prefix }}") "admins !requiretty

# This variable is used to configure access by Ansible Controller hosts
Defaults: %" (jinja "{{ system_groups__prefix }}") "admins env_check += \"SSH_CLIENT\"

# Allow execution of any command as any user on the system.
# This is required for Ansible operation.
" (jinja "{{ ('%' + system_groups__prefix + 'admins ALL = (ALL:ALL) '
    + ('NOPASSWD: ' if system_groups__admins_sudo_nopasswd | bool else '')
    + 'ALL') }}") "
")
      (members (jinja "{{ ansible_local.core.admin_users | d([]) }}"))
      (access (list
          "root"
          "sshd"))
      
      (name (jinja "{{ system_groups__prefix }}") "wheel")
      (sudoers_filename "system_groups-wheel")
      (sudoers "# This might be required to allow Ansible pipelining connections
Defaults: %" (jinja "{{ system_groups__prefix }}") "wheel !requiretty

# This variable is used to configure access by Ansible Controller hosts
Defaults: %" (jinja "{{ system_groups__prefix }}") "wheel env_check += \"SSH_CLIENT\"

# Allow execution of any command as any user on the system.
# This is required for Ansible operation.
" (jinja "{{ ('%' + system_groups__prefix + 'wheel ALL = (ALL:ALL) '
    + ('NOPASSWD: ' if system_groups__admins_sudo_nopasswd | bool else '')
    + 'ALL') }}") "
")
      (members (jinja "{{ ansible_local.core.admin_users | d([]) }}"))
      (access (list
          "root"
          "sshd"))
      (state "init")
      
      (name "adm")
      (members (jinja "{{ ansible_local.core.admin_users | d([]) }}"))
      
      (name "staff")
      (members (jinja "{{ ansible_local.core.admin_users | d([]) }}"))
      
      (name (jinja "{{ system_groups__prefix }}") "sshusers")
      (access (list
          "sshd"))
      
      (name (jinja "{{ system_groups__prefix }}") "sftponly")
      (access (list
          "sshd"))
      
      (name (jinja "{{ system_groups__prefix }}") "webadmins")
      (access (list
          "webserver"))))
  (system_groups__list (list))
  (system_groups__group_list (list))
  (system_groups__host_list (list))
  (system_groups__dependent_list (list))
  (system_groups__combined_list (jinja "{{ system_groups__default_list
                                  + system_groups__dependent_list
                                  + system_groups__list
                                  + system_groups__group_list
                                  + system_groups__host_list }}")))
