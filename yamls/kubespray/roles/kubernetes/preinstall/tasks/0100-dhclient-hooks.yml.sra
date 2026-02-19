(playbook "kubespray/roles/kubernetes/preinstall/tasks/0100-dhclient-hooks.yml"
  (tasks
    (task "Configure dhclient to supersede search/domain/nameservers"
      (blockinfile 
        (block (jinja "{% for key, val in dhclient_supersede.items() | rejectattr(1, '==', []) -%}") "
" (jinja "{% if key == \"domain-name-servers\" -%}") "
supersede " (jinja "{{ key }}") " " (jinja "{{ val | join(',') }}") ";
" (jinja "{% else -%}") "
supersede " (jinja "{{ key }}") " \"" (jinja "{{ val | join('\",\"') }}") "\";
" (jinja "{% endif -%}") "
" (jinja "{% endfor %}"))
        (path (jinja "{{ dhclientconffile }}"))
        (create "true")
        (state "present")
        (insertbefore "BOF")
        (backup (jinja "{{ leave_etc_backup_files }}"))
        (marker "# Ansible entries {mark}")
        (mode "0644"))
      (notify "Preinstall | propagate resolvconf to k8s components"))
    (task "Configure dhclient hooks for resolv.conf (non-RH)"
      (template 
        (src "dhclient_dnsupdate.sh.j2")
        (dest (jinja "{{ dhclienthookfile }}"))
        (owner "root")
        (mode "0755"))
      (notify "Preinstall | propagate resolvconf to k8s components")
      (when "ansible_os_family not in [ \"RedHat\", \"Suse\" ]"))
    (task "Configure dhclient hooks for resolv.conf (RH-only)"
      (template 
        (src "dhclient_dnsupdate_rh.sh.j2")
        (dest (jinja "{{ dhclienthookfile }}"))
        (owner "root")
        (mode "0755"))
      (notify "Preinstall | propagate resolvconf to k8s components")
      (when "ansible_os_family == \"RedHat\""))))
