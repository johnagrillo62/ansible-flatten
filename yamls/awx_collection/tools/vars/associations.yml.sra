(playbook "awx_collection/tools/vars/associations.yml"
  (associations 
    (job_templates (list
        
        (related_item "credentials")
        (endpoint "credentials")
        (description "The credentials used by this job template")
        (required "false")))
    (groups (list
        
        (related_item "hosts")
        (endpoint "hosts")
        (description "The hosts associated with this group")
        (required "false")
        
        (related_item "groups")
        (endpoint "children")
        (description "The hosts associated with this group")
        (required "false")))))
