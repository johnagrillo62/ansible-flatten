(playbook "debops/ansible/roles/ntp/tasks/openntpd.yml"
  (tasks
    (task "Divert OpenNTPd configuration files"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ item }}")))
      (loop (list
          "/etc/default/openntpd"
          "/etc/openntpd/ntpd.conf"
          "/etc/network/if-up.d/openntpd")))
    (task "Configure OpenNTPd"
      (ansible.builtin.template 
        (src (jinja "{{ item.name }}") ".j2")
        (dest "/" (jinja "{{ item.name }}"))
        (owner "root")
        (group "root")
        (mode (jinja "{{ item.mode | d(\"0644\") }}")))
      (with_items (list
          
          (name "etc/default/openntpd")
          
          (name "etc/openntpd/ntpd.conf")
          
          (name "etc/network/if-up.d/openntpd")
          (mode "0755")
          
          (name "etc/dpkg/dpkg.cfg.d/debops-ntp-openntpd")
          
          (name "usr/local/lib/debops-ntp-openntpd-dpkg-cleanup")
          (mode "0755")))
      (notify (list
          "Restart openntpd")))))
