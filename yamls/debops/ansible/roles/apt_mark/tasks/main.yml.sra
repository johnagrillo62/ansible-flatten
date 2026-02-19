(playbook "debops/ansible/roles/apt_mark/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Configure APT autoremove options"
      (ansible.builtin.template 
        (src "etc/apt/apt.conf.d/25autoremove-recommends.conf.j2")
        (dest "/etc/apt/apt.conf.d/25autoremove-recommends.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "apt_mark__enabled | bool"))
    (task "Check state of the APT packages"
      (ansible.builtin.script "script/apt-mark-status" (jinja "{{ \"2\" if (ansible_python_version is version_compare(\"3.5\", \"<\")) else \"3\" }}"))
      (register "apt_mark__register_state")
      (changed_when "False")
      (check_mode "False")
      (when "apt_mark__enabled | bool"))
    (task "Set facts about APT package state"
      (ansible.builtin.set_fact 
        (apt_mark__fact_auto (jinja "{{ (apt_mark__register_state.stdout | from_json)[\"auto\"] }}"))
        (apt_mark__fact_hold (jinja "{{ (apt_mark__register_state.stdout | from_json)[\"hold\"] }}"))
        (apt_mark__fact_installed (jinja "{{ (apt_mark__register_state.stdout | from_json)[\"installed\"] }}"))
        (apt_mark__fact_manual (jinja "{{ (apt_mark__register_state.stdout | from_json)[\"manual\"] }}")))
      (when "apt_mark__enabled | bool"))
    (task "Set package state as installed automatically"
      (ansible.builtin.command "apt-mark auto " (jinja "{{ ((item.packages | d([item.name])) | intersect(apt_mark__fact_installed)) | join(' ') }}"))
      (with_items (jinja "{{ apt_mark__combined_packages | debops.debops.parse_kv_items }}"))
      (register "apt_mark__register_auto")
      (changed_when "apt_mark__register_auto.changed | bool")
      (when "(apt_mark__enabled | bool and (item.packages | d([item.name]) | intersect(apt_mark__fact_installed)) | symmetric_difference(apt_mark__fact_manual) and (item.packages | d([item.name]) | intersect(apt_mark__fact_installed)) | difference(apt_mark__fact_auto) and item.state | d('manual') in ['auto', 'auto-hold', 'auto-unhold'])"))
    (task "Set package state as installed manually"
      (ansible.builtin.command "apt-mark manual " (jinja "{{ ((item.packages | d([item.name]))
                               | intersect(apt_mark__fact_installed)) | join(' ') }}"))
      (with_items (jinja "{{ apt_mark__combined_packages | debops.debops.parse_kv_items }}"))
      (register "apt_mark__register_manual")
      (changed_when "apt_mark__register_manual.changed | bool")
      (when "(apt_mark__enabled | bool and (item.packages | d([item.name]) | intersect(apt_mark__fact_installed)) | symmetric_difference(apt_mark__fact_auto) and (item.packages | d([item.name]) | intersect(apt_mark__fact_installed)) | difference(apt_mark__fact_manual) and item.state | d('manual') in ['manual', 'manual-hold', 'manual-unhold'])"))
    (task "Hold current package state"
      (ansible.builtin.command "apt-mark hold " (jinja "{{ ((item.packages | d([item.name]))
                             | intersect(apt_mark__fact_installed)) | join(' ') }}"))
      (with_items (jinja "{{ apt_mark__combined_packages | debops.debops.parse_kv_items }}"))
      (register "apt_mark__register_hold")
      (changed_when "apt_mark__register_hold.changed | bool")
      (when "(apt_mark__enabled | bool and (item.packages | d([item.name]) | intersect(apt_mark__fact_installed)) | difference(apt_mark__fact_hold) and item.state | d('manual') in ['hold', 'auto-hold', 'manual-hold'])"))
    (task "Unhold current package state"
      (ansible.builtin.command "apt-mark unhold " (jinja "{{ ((item.packages | d([item.name]))
                               | intersect(apt_mark__fact_installed)) | join(' ') }}"))
      (with_items (jinja "{{ apt_mark__combined_packages | debops.debops.parse_kv_items }}"))
      (register "apt_mark__register_unhold")
      (changed_when "apt_mark__register_unhold.changed | bool")
      (when "(apt_mark__enabled | bool and (item.packages | d([item.name]) | intersect(apt_mark__fact_installed)) | intersect(apt_mark__fact_hold) and item.state | d('manual') in ['unhold', 'auto-unhold', 'manual-unhold'])"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save apt-mark local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/apt_mark.fact.j2")
        (dest "/etc/ansible/facts.d/apt_mark.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (tags (list
          "meta::facts")))))
