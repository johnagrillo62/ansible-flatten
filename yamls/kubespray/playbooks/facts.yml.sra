(playbook "kubespray/playbooks/facts.yml"
  (tasks
    (task "Common tasks for every playbooks"
      (import_playbook "boilerplate.yml"))
    (task "Gather facts"
      (import_playbook "internal_facts.yml"))))
