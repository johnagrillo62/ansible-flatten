(playbook "debops/ansible/playbooks/service/apt_mark.yml"
    (play
    (name "Mark APT package state")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_apt_mark"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "apt_mark")
        (tags (list
            "role::apt_mark"
            "skip::apt_mark")))))
