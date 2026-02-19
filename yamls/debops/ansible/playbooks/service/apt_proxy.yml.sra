(playbook "debops/ansible/playbooks/service/apt_proxy.yml"
    (play
    (name "Configure APT proxy")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_apt_proxy"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "apt_proxy")
        (tags (list
            "role::apt_proxy"
            "skip::apt_proxy")))))
