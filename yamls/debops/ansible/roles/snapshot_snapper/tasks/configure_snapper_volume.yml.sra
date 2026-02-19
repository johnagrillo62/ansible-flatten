(playbook "debops/ansible/roles/snapshot_snapper/tasks/configure_snapper_volume.yml"
  (tasks
    (task "Configure snapper volume"
      (ansible.builtin.lineinfile 
        (dest "/etc/snapper/configs/" (jinja "{{ snapshot_snapper__volume.name }}"))
        (regexp "^" (jinja "{{ item.key }}") "=")
        (line (jinja "{{ item.key }}") "=\"" (jinja "{{ item.value }}") "\"")
        (mode "0644"))
      (with_dict (jinja "{{ (snapshot_snapper__templates_combined[snapshot_snapper__volume.template | d(\"default\")] | d({}))
                 | combine(snapshot_snapper__volume.config | d({})) }}")))))
