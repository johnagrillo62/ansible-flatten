(playbook "debops/ansible/playbooks/service/postwhite.yml"
    (play
    (name "Manage Postwhite service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_postwhite"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare postfix environment"
        (ansible.builtin.import_role 
          (name "postfix")
          (tasks_from "main_env"))
        (vars 
          (postfix__dependent_maincf (list
              
              (role "postwhite")
              (config (jinja "{{ postwhite__postfix__dependent_maincf }}")))))
        (when "(ansible_local | d() and ansible_local.postfix | d() and (ansible_local.postfix.installed | d()) | bool)")
        (tags (list
            "role::postfix"
            "role::secret"))))
    (roles
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::postfix"))
        (secret__directories (list
            (jinja "{{ postfix__secret__directories }}")))
        (when "(ansible_local | d() and ansible_local.postfix | d() and (ansible_local.postfix.installed | d()) | bool)")
      
        (role "postfix")
        (tags (list
            "role::postfix"
            "skip::postfix"))
        (postfix__dependent_maincf (list
            
            (role "postwhite")
            (config (jinja "{{ postwhite__postfix__dependent_maincf }}"))))
        (when "(ansible_local | d() and ansible_local.postfix | d() and (ansible_local.postfix.installed | d()) | bool)")
      
        (role "postwhite")
        (tags (list
            "role::postwhite"
            "skip::postwhite")))))
