(playbook "sensu-ansible/molecule/shared/prepare.yml"
    (play
    (name "Prepare")
    (hosts "all")
    (gather_facts "false")
    (tasks)))
