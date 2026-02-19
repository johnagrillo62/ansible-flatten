(playbook "debops/ansible/roles/apparmor/tasks/handle_profiles.yml"
  (tasks
    (task "Ensure a valid state for profile " (jinja "{{ item.name }}")
      (ansible.builtin.assert 
        (that "item.state | d() in [ \"enforce\", \"complain\", \"disable\", \"ignore\" ]")
        (quiet "True"))
      (tags (list
          "role::apparmor:profiles")))
    (task "Check presence of profile " (jinja "{{ item.name }}")
      (ansible.builtin.stat 
        (path (jinja "{{ \"/etc/apparmor.d/\" + item.name }}")))
      (register "apparmor__stat_profile")
      (when "item.state != \"ignore\"")
      (tags (list
          "role::apparmor:profiles")))
    (task "Ensure existence of profile " (jinja "{{ item.name }}")
      (ansible.builtin.assert 
        (that "apparmor__stat_profile.stat.exists | d(False)")
        (quiet "True"))
      (when "item.state != \"ignore\"")
      (tags (list
          "apparmor:profiles")))
    (task "Register current AppArmor state"
      (ansible.builtin.command "aa-status --json")
      (register "apparmor__register_old_status")
      (changed_when "False")
      (when "item.state != \"ignore\"")
      (tags (list
          "role::apparmor:profiles")))
    (task "Set profile " (jinja "{{ item.name + \" to \" + item.state }}")
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && aa-" (jinja "{{ item.state }}") " " (jinja "{{ (\"/etc/apparmor.d/\" + item.name) | quote }}") " > /dev/null 2>&1 && aa-status --json")
      (args 
        (executable "bash"))
      (register "apparmor__register_new_status")
      (changed_when "apparmor__register_new_status.stdout != apparmor__register_old_status.stdout")
      (when "item.state != \"ignore\"")
      (tags (list
          "role::apparmor:profiles")))))
