(playbook "debops/ansible/playbooks/service/resolvconf.yml"
    (play
    (name "Manage system-wide DNS resolver configuration")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_resolvconf"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "resolvconf")
        (tags (list
            "role::resolvconf"
            "skip::resolvconf")))))
