(playbook "debops/ansible/roles/owncloud/tasks/deploy_state_absent.yml"
  (tasks
    (task "Remove shortcut for the occ command"
      (ansible.builtin.file 
        (path (jinja "{{ owncloud__occ_bin_file_path }}"))
        (state "absent"))
      (tags (list
          "role::owncloud:occ")))))
