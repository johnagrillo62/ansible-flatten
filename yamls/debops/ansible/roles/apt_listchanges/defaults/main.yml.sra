(playbook "debops/ansible/roles/apt_listchanges/defaults/main.yml"
  (apt_listchanges__deploy_state "present")
  (apt_listchanges__base_packages (list
      "apt-listchanges"))
  (apt_listchanges__packages (list))
  (apt_listchanges__mail_to (jinja "{{ ansible_local.core.admin_private_email | d([\"root\"]) }}"))
  (apt_listchanges__apt_frontend (jinja "{{ \"none\"
                                   if (ansible_local | d() and ansible_local.apticron | d() and
                                       ansible_local.apticron.enabled | bool)
                                   else (ansible_local.apt_listchanges.apt.frontend
                                         if (ansible_local.apt_listchanges.apt | d() and
                                             ansible_local.apt_listchanges.apt.frontend | d())
                                         else \"mail\") }}"))
  (apt_listchanges__apt_which "news")
  (apt_listchanges__apticron_frontend "mail")
  (apt_listchanges__apticron_which "both")
  (apt_listchanges__profiles 
    (cmdline (jinja "{{ apt_listchanges__profile_cmdline }}"))
    (apt (jinja "{{ apt_listchanges__profile_apt }}"))
    (apticron (jinja "{{ apt_listchanges__profile_apticron }}")))
  (apt_listchanges__profile_cmdline 
    (frontend "pager"))
  (apt_listchanges__profile_apt 
    (frontend (jinja "{{ apt_listchanges__apt_frontend }}"))
    (email_address (jinja "{{ apt_listchanges__mail_to | join(\",\") }}"))
    (confirm "0")
    (which (jinja "{{ apt_listchanges__apt_which }}"))
    (save_seen "/var/lib/apt/listchanges.db"))
  (apt_listchanges__profile_apticron 
    (frontend (jinja "{{ apt_listchanges__apticron_frontend }}"))
    (email_address (jinja "{{ apt_listchanges__mail_to | join(\",\") }}"))
    (confirm "0")
    (which (jinja "{{ apt_listchanges__apticron_which }}"))
    (save_seen "/var/lib/apt/listchanges.db")))
