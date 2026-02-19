(playbook "debops/ansible/roles/machine/defaults/main.yml"
  (machine__enabled "True")
  (machine__packages (list))
  (machine__organization (jinja "{{ ansible_domain.split(\".\")[0] | capitalize }}"))
  (machine__contact (jinja "{{ ansible_local.core.admin_public_email[0]
                      | d(\"root@\" + ansible_domain) }}"))
  (machine__pretty_hostname "")
  (machine__icon_name "")
  (machine__chassis "")
  (machine__deployment "production")
  (machine__location "")
  (machine__motd "")
  (machine__etc_motd_state (jinja "{{ \"present\" if machine__motd | d() else \"absent\" }}"))
  (machine__motd_update_dir "/etc/update-motd.d")
  (machine__etc_issue_state "present")
  (machine__etc_issue_template "etc/issue.j2")
  (machine__motd_default_scripts (list
      
      (name "uname")
      (filename "10-uname")
      (divert "True")
      (content "#!/bin/sh
uname -snrvm
")
      (state "init")
      
      (name "ansible")
      (weight "50")
      (src "etc/update-motd.d/ansible")
      (state "present")
      
      (name "tail")
      (weight "90")
      (content "#!/bin/sh
if [ -f /etc/motd.tail ] ; then
    cat /etc/motd.tail
fi
")
      (state "present")
      
      (name "fortune")
      (weight "95")
      (src "etc/update-motd.d/fortune")
      (state "init")))
  (machine__motd_scripts (list))
  (machine__motd_group_scripts (list))
  (machine__motd_host_scripts (list))
  (machine__motd_combined_scripts (jinja "{{ machine__motd_default_scripts
                                    + machine__motd_scripts
                                    + machine__motd_group_scripts
                                    + machine__motd_host_scripts }}")))
