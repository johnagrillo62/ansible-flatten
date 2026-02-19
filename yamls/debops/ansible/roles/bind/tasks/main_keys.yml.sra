(playbook "debops/ansible/roles/bind/tasks/main_keys.yml"
  (tasks
    (task "Create sanitised list of keys"
      (ansible.builtin.set_fact 
        (bind__tmp_keys (jinja "{{ bind__tmp_keys | d([])
                        + [item | combine({\"state\": item.state | d(\"present\") | lower,
                                           \"type\": item.type | mandatory | upper,
                                           \"dir\": item.dir | d(\"/etc/bind/keys/\"),
                                           \"owner\": item.owner | d(\"root\"),
                                           \"group\": item.group | d(\"bind\"),
                                           \"include\": (item.include | d(True) | bool)
                                                      if item.type | d(\"\") | upper == \"TSIG\"
                                                      else False,
                                           \"download\": item.download | d(True if item.source | d(\"host\") == \"host\" else False) | bool,
                                           \"source\": item.source | d(\"host\"),
                                           \"source_path\": item.source_path | d(\"\"),
                                           \"remove_private_key\": item.remove_private_key | d(True) | bool,
                                           \"algorithm\": (item.algorithm | mandatory)
                                                        if item.type | d(\"\") | upper == \"TSIG\"
                                                        else (\"%03d\" | format(item.algorithm | mandatory | int))
                                                        if item.type | d(\"\") | upper == \"SIG(0)\"
                                                        else omit,
                                           \"creates\": (item.name + \".key\")
                                                      if item.type | d(\"\") | upper == \"TSIG\"
                                                      else (\"K\" + item.name + \"+\" + \"%03d\" | format(item.algorithm | int) + \"+*.key\")
                                                      if item.type | d(\"\") | upper == \"SIG(0)\"
                                                      else omit,
                                           \"removes\": (item.name + \".key\")
                                                      if item.type | d(\"\") | upper == \"TSIG\"
                                                      else (\"K\" + item.name + \"+\" + \"%03d\" | format(item.algorithm | int) + \"+*.*\")
                                                      if item.type | d(\"\") | upper == \"SIG(0)\"
                                                      else omit,
                                           \"public_key\": (item.name + \".key\")
                                                         if item.type | d(\"\") | upper == \"TSIG\"
                                                         else (\"K\" + item.name + \"+\" + \"%03d\" | format(item.algorithm | int) + \"+*.key\")
                                                         if item.type | d(\"\") | upper == \"SIG(0)\"
                                                         else omit,
                                           \"private_key\": (item.name + \".key\")
                                                          if item.type | d(\"\") | upper == \"TSIG\"
                                                          else (\"K\" + item.name + \"+\" + \"%03d\" | format(item.algorithm | int) + \"+*.private\")
                                                          if item.type | d(\"\") | upper == \"SIG(0)\"
                                                          else omit})] }}")))
      (when (list
          "item.name | d(\"\") | length > 0"
          "item.state | d(\"present\") | lower in [ 'present', 'absent' ]"))
      (loop (jinja "{{ bind__combined_keys | d([]) | debops.debops.parse_kv_items(name=\"name\") }}"))
      (loop_control 
        (label (jinja "{{ item.name | d(\"unknown\") }}")))
      (tags (list
          "role::bind:config"
          "role::bind:keys")))
    (task "Verify key sanity"
      (ansible.builtin.assert 
        (that (list
            "item.name | regex_replace('([^a-zA-Z0-9-.])', '') == item.name"
            "item.type in [ 'TSIG', 'SIG(0)' ]"
            "item.algorithm != \"000\""
            "item.source in [ \"host\", \"controller\" ]"
            "not (item.download and item.source == \"controller\")"))
        (quiet "true"))
      (loop (jinja "{{ bind__tmp_keys | d([]) }}"))
      (loop_control 
        (label (jinja "{{ item.name }}")))
      (tags (list
          "role::bind:config"
          "role::bind:keys")))
    (task "Create TSIG keys"
      (ansible.builtin.shell 
        (chdir (jinja "{{ item.dir }}"))
        (cmd "umask 027; tsig-keygen -a " (jinja "{{ item.algorithm | quote }}") " " (jinja "{{ item.name | quote }}") " > " (jinja "{{ item.creates | quote }}") " && chown " (jinja "{{ (item.owner + \":\" + item.group) | quote }}") " " (jinja "{{ item.creates | quote }}"))
        (creates (jinja "{{ item.creates }}")))
      (when (list
          "item.state == 'present'"
          "item.type == 'TSIG'"
          "item.source == 'host'"))
      (loop (jinja "{{ bind__tmp_keys | d([]) }}"))
      (loop_control 
        (label (jinja "{{ item.name }}")))
      (notify (list
          "Test named configuration and restart"))
      (tags (list
          "role::bind:keys")))
    (task "Fetch TSIG keys"
      (ansible.builtin.fetch 
        (src (jinja "{{ item.dir + \"/\" + item.public_key }}"))
        (dest (jinja "{{ secret + \"/bind/\" + inventory_hostname + \"/\" }}"))
        (flat "True"))
      (when (list
          "item.state == 'present'"
          "item.type == 'TSIG'"
          "item.download"))
      (loop (jinja "{{ bind__tmp_keys | d([]) }}"))
      (loop_control 
        (label (jinja "{{ item.name }}")))
      (tags (list
          "role::bind:keys")))
    (task "Create SIG(0) keys"
      (ansible.builtin.shell 
        (chdir (jinja "{{ item.dir }}"))
        (cmd "umask 027; dnssec-keygen -C -a " (jinja "{{ item.algorithm | quote }}") " -n HOST -T KEY " (jinja "{{ item.name | quote }}") " && chown " (jinja "{{ (item.owner + \":\" + item.group) | quote }}") " " (jinja "{{ item.creates }}"))
        (creates (jinja "{{ item.creates }}")))
      (when (list
          "item.state == 'present'"
          "item.type == 'SIG(0)'"))
      (loop (jinja "{{ bind__tmp_keys | d([]) }}"))
      (loop_control 
        (label (jinja "{{ item.name }}")))
      (notify (list
          "Test named configuration and restart"))
      (tags (list
          "role::bind:keys")))
    (task "Find SIG(0) keys to fetch"
      (ansible.builtin.find 
        (paths (jinja "{{ item.dir }}"))
        (use_regex "False")
        (recurse "False")
        (patterns (list
            (jinja "{{ item.public_key }}")
            (jinja "{{ item.private_key }}"))))
      (when (list
          "item.state == 'present'"
          "item.type == 'SIG(0)'"
          "item.download"))
      (register "bind__tmp_find_sig0_keys")
      (loop (jinja "{{ bind__tmp_keys | d([]) }}"))
      (loop_control 
        (label (jinja "{{ item.name }}")))
      (tags (list
          "role::bind:keys")))
    (task "Build combined list of SIG(0) keys to fetch"
      (ansible.builtin.set_fact 
        (bind__tmp_sig0_fetch (jinja "{{ bind__tmp_sig0_fetch | d([]) + item.files | map(attribute=\"path\") }}")))
      (loop (jinja "{{ bind__tmp_find_sig0_keys.results | d([]) }}"))
      (when "item.files is defined")
      (loop_control 
        (label (jinja "{{ item.item.name }}")))
      (tags (list
          "role::bind:keys")))
    (task "Fetch SIG(0) keys"
      (ansible.builtin.fetch 
        (src (jinja "{{ item }}"))
        (dest (jinja "{{ secret + \"/bind/\" + inventory_hostname + \"/\" }}"))
        (flat "True"))
      (loop (jinja "{{ bind__tmp_sig0_fetch | d([]) }}"))
      (tags (list
          "role::bind:keys")))
    (task "Find SIG(0) private keys to remove"
      (ansible.builtin.find 
        (paths (jinja "{{ item.dir }}"))
        (use_regex "False")
        (recurse "False")
        (patterns (list
            (jinja "{{ item.private_key }}"))))
      (when (list
          "item.state == 'present'"
          "item.type == 'SIG(0)'"
          "item.remove_private_key"))
      (register "bind__tmp_find_sig0_keys")
      (loop (jinja "{{ bind__tmp_keys | d([]) }}"))
      (loop_control 
        (label (jinja "{{ item.name }}")))
      (tags (list
          "role::bind:keys")))
    (task "Build combined list of SIG(0) private keys to remove"
      (ansible.builtin.set_fact 
        (bind__tmp_sig0_remove (jinja "{{ bind__tmp_sig0_remove | d([]) + item.files | d([]) | map(attribute=\"path\") }}")))
      (loop (jinja "{{ bind__tmp_find_sig0_keys.results | d([]) }}"))
      (when "item.files is defined")
      (loop_control 
        (label (jinja "{{ item.item.name }}")))
      (tags (list
          "role::bind:keys")))
    (task "Remove SIG(0) private keys"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "absent"))
      (loop (jinja "{{ bind__tmp_sig0_remove | d([]) }}"))
      (tags (list
          "role::bind:keys")))
    (task "Remove TSIG/SIG(0) keys configured as absent"
      (ansible.builtin.shell 
        (chdir (jinja "{{ item.dir }}"))
        (cmd "rm -f " (jinja "{{ item.removes }}"))
        (removes (jinja "{{ item.removes }}")))
      (when (list
          "item.state == 'absent'"))
      (loop (jinja "{{ bind__tmp_keys | d([]) }}"))
      (loop_control 
        (label (jinja "{{ item.name }}")))
      (notify (list
          "Test named configuration and restart"))
      (tags (list
          "role::bind:keys")))
    (task "Upload TSIG/SIG(0) keys from the controller"
      (ansible.builtin.copy 
        (src (jinja "{{ item.source_path if item.source_path.startswith(\"/\") else secret + \"/\" + item.source_path }}"))
        (dest (jinja "{{ item.dir + \"/\" + item.source_path | basename }}"))
        (owner (jinja "{{ item.owner }}"))
        (group (jinja "{{ item.group }}"))
        (mode "0640"))
      (when (list
          "item.state == 'present'"
          "item.source == 'controller'"))
      (loop (jinja "{{ bind__tmp_keys | d([]) }}"))
      (loop_control 
        (label (jinja "{{ item.name }}")))
      (notify (list
          "Test named configuration and restart"))
      (tags (list
          "role::bind:keys")))))
