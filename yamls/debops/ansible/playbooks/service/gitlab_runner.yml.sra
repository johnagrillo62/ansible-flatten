(playbook "debops/ansible/playbooks/service/gitlab_runner.yml"
    (play
    (name "Manage GitLab Runner service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_gitlab_runner"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::gitlab_runner"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ gitlab_runner__keyring__dependent_apt_keys }}")))
      
        (role "gitlab_runner")
        (tags (list
            "role::gitlab_runner"
            "skip::gitlab_runner")))))
