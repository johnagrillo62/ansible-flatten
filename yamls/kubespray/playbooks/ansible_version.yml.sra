(playbook "kubespray/playbooks/ansible_version.yml"
    (play
    (name "Check Ansible version")
    (hosts "all")
    (gather_facts "false")
    (become "false")
    (run_once "true")
    (vars
      (minimal_ansible_version "2.18.0")
      (maximal_ansible_version "2.19.0"))
    (tags "always")
    (tasks
      (task "Check " (jinja "{{ minimal_ansible_version }}") " <= Ansible version < " (jinja "{{ maximal_ansible_version }}")
        (assert 
          (msg "Ansible must be between " (jinja "{{ minimal_ansible_version }}") " and " (jinja "{{ maximal_ansible_version }}") " exclusive - you have " (jinja "{{ ansible_version.string }}"))
          (that (list
              "ansible_version.string is version(minimal_ansible_version, \">=\")"
              "ansible_version.string is version(maximal_ansible_version, \"<\")")))
        (tags (list
            "check")))
      (task "Check that python netaddr is installed"
        (assert 
          (msg "Python netaddr is not present")
          (that "'127.0.0.1' | ansible.utils.ipaddr"))
        (tags (list
            "check")))
      (task "Check that jinja is not too old (install via pip)"
        (assert 
          (msg "Your Jinja version is too old, install via pip")
          (that (jinja "{% set test %}") "It works" (jinja "{% endset %}") (jinja "{{ test == 'It works' }}")))
        (tags (list
            "check"))))))
