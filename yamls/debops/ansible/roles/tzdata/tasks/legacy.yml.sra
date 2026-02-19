(playbook "debops/ansible/roles/tzdata/tasks/legacy.yml"
  (tasks
    (task "Configure tzdata area in debconf"
      (ansible.builtin.debconf 
        (name "tzdata")
        (question "tzdata/Areas")
        (vtype "select")
        (value (jinja "{{ tzdata__timezone.split(\"/\")[0] }}")))
      (register "tzdata__register_debconf_set_area")
      (notify (list
          "Refresh host facts"))
      (when "tzdata__enabled | bool"))
    (task "Configure tzdata zone in debconf"
      (ansible.builtin.debconf 
        (name "tzdata")
        (question "tzdata/Zones/" (jinja "{{ tzdata__timezone.split(\"/\")[0] }}"))
        (vtype "select")
        (value (jinja "{{ tzdata__timezone.split(\"/\")[1] }}")))
      (register "tzdata__register_debconf_set_zone")
      (notify (list
          "Refresh host facts"))
      (when "tzdata__enabled | bool"))
    (task "Configure timezone in /etc/timezone"
      (ansible.builtin.copy 
        (content (jinja "{{ tzdata__timezone }}"))
        (dest "/etc/timezone")
        (mode "0644"))
      (register "tzdata__register_etc_timezone")
      (notify (list
          "Refresh host facts"))
      (when "tzdata__enabled | bool"))
    (task "Check if /etc/localtime is a symlink"
      (ansible.builtin.stat 
        (path "/etc/localtime"))
      (register "tzdata__register_etc_localtime")
      (when "tzdata__enabled | bool"))
    (task "Symlink correct timezone as /etc/localtime"
      (ansible.builtin.file 
        (path "/etc/localtime")
        (src "/usr/share/zoneinfo/" (jinja "{{ tzdata__timezone }}"))
        (state "link")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (when "(tzdata__enabled | bool and tzdata__register_etc_timezone is changed and tzdata__register_etc_localtime.stat.islnk | bool)"))
    (task "Reconfigure tzdata"
      (ansible.builtin.command "dpkg-reconfigure --frontend noninteractive tzdata")
      (register "tzdata__register_dpkg_reconfigure")
      (changed_when "tzdata__register_dpkg_reconfigure.changed | bool")
      (when "(tzdata__enabled | bool and (tzdata__register_debconf_set_area is changed or tzdata__register_debconf_set_zone is changed or tzdata__register_etc_timezone is changed))"))))
