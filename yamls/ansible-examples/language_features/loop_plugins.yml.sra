(playbook "ansible-examples/language_features/loop_plugins.yml"
    (play
    (hosts "all")
    (gather_facts "no")
    (tasks
      (task
        (file "dest=/etc/fooapp state=directory"))
      (task
        (copy "src=" (jinja "{{ item }}") " dest=/etc/fooapp/ owner=root mode=600")
        (with_fileglob "/playbooks/files/fooapp/*")))))
