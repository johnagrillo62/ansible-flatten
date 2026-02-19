(playbook "debops/ansible/playbooks/service/pam_access.yml"
    (play
    (name "Manage PAM Access Control Lists")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_pam_access"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "pam_access")
        (tags (list
            "role::pam_access"
            "skip::pam_access")))))
