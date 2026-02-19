(playbook "awx_collection/tools/roles/generate/tasks/main.yml"
  (tasks
    (task "Get date time data"
      (setup 
        (gather_subset "min")))
    (task "Create module directory"
      (file 
        (state "directory")
        (name "modules")))
    (task "Load api/v2"
      (uri 
        (method "GET")
        (url (jinja "{{ api_url }}") "/api/v2/"))
      (register "endpoints"))
    (task "Load endpoint options"
      (uri 
        (method "OPTIONS")
        (url (jinja "{{ api_url }}") (jinja "{{ item.value }}")))
      (loop (jinja "{{ endpoints['json'] | dict2items }}"))
      (loop_control 
        (label (jinja "{{ item.key }}")))
      (register "end_point_options")
      (when "generate_for is not defined or item.key in generate_for"))
    (task "Scan POST options for different things"
      (set_fact 
        (all_options (jinja "{{ all_options | default({}) | combine(options[0]) }}")))
      (loop (jinja "{{ end_point_options.results }}"))
      (vars 
        (options (jinja "{{ item | json_query('json.actions.POST.[*]') }}")))
      (loop_control 
        (label (jinja "{{ item['item']['key'] }}")))
      (when (list
          "item is not skipped"
          "options is defined")))
    (task "Process endpoint"
      (template 
        (src "templates/tower_module.j2")
        (dest (jinja "{{ playbook_dir | dirname }}") "/plugins/modules/" (jinja "{{ file_name }}")))
      (loop (jinja "{{ end_point_options['results'] }}"))
      (loop_control 
        (label (jinja "{{ item['item']['key'] }}")))
      (when "'json' in item and 'actions' in item['json'] and 'POST' in item['json']['actions']")
      (vars 
        (item_type (jinja "{{ item['item']['key'] }}"))
        (human_readable (jinja "{{ item_type | replace('_', ' ') }}"))
        (singular_item_type (jinja "{{ item['item']['key'] | regex_replace('ies$', 'y') | regex_replace('s$', '') }}"))
        (file_name "tower_" (jinja "{% if item['item']['key'] in ['settings'] %}") (jinja "{{ item['item']['key'] }}") (jinja "{% else %}") (jinja "{{ singular_item_type }}") (jinja "{% endif %}") ".py")
        (type_map 
          (bool "bool")
          (boolean "bool")
          (choice "str")
          (datetime "str")
          (id "str")
          (int "int")
          (integer "int")
          (json "dict")
          (list "list")
          (object "dict")
          (password "str")
          (string "str"))))))
