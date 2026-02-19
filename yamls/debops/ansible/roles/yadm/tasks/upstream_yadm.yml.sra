(playbook "debops/ansible/roles/yadm/tasks/upstream_yadm.yml"
  (tasks
    (task "Clone the yadm upstream repository"
      (ansible.builtin.git 
        (repo (jinja "{{ yadm__upstream_repo }}"))
        (dest (jinja "{{ yadm__upstream_dest }}"))
        (version (jinja "{{ yadm__upstream_version }}"))
        (verify_commit "True")))
    (task "Symlink the upstream yadm binary in $PATH"
      (ansible.builtin.file 
        (dest (jinja "{{ yadm__upstream_link }}"))
        (src (jinja "{{ yadm__upstream_dest + \"/yadm\" }}"))
        (state "link")
        (mode "0755")))))
