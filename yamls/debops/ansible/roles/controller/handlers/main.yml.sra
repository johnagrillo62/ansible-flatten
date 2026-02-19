(playbook "debops/ansible/roles/controller/handlers/main.yml"
  (tasks
    (task "Update DebOps in the background with async"
      (ansible.builtin.command "debops-update")
      (async (jinja "{{ controller__async_timeout | int }}"))
      (poll "0")
      (become (jinja "{{ controller__install_systemwide | bool }}"))
      (register "controller__register_update_async")
      (changed_when "controller__register_update_async.changed | bool")
      (when "not controller__update_method == 'sync'"))
    (task "Update DebOps in the background with batch"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit &&
type debops-update > /dev/null 2>&1 && (echo 'debops-update' | batch > /dev/null 2>&1) || true
")
      (become (jinja "{{ controller__install_systemwide | bool }}"))
      (args 
        (executable "bash"))
      (register "controller__register_update_batch")
      (changed_when "controller__register_update_batch.changed | bool")
      (when "(not controller__update_method == 'sync' and (ansible_local | d() and ansible_local.atd | d() and ansible_local.atd.enabled | bool))"))))
