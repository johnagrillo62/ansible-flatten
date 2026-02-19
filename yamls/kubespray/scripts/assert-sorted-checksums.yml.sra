(playbook "kubespray/scripts/assert-sorted-checksums.yml"
    (play
    (name "Verify correct structure of Kubespray variables")
    (hosts "localhost")
    (connection "local")
    (gather_facts "false")
    (vars
      (fallback_ip "bypass tasks in kubespray_defaults")
      (_keys (jinja "{{ query('ansible.builtin.varnames', '^.+_checksums$') }}"))
      (_values (jinja "{{ query('ansible.builtin.vars', *_keys) | map('dict2items') }}"))
      (_components_archs_values (jinja "{{ _keys | zip(_values) | community.general.dict | dict2items | subelements('value') }}"))
      (_minimal_data_needed (jinja "{{ _components_archs_values | map(attribute='0.key') | zip(_components_archs_values | map(attribute='1')) }}")))
    (roles
      "kubespray_defaults")
    (tasks
      (task "Check all versions are strings"
        (assert 
          (that (jinja "{{ item.1.value | reject('string') == [] }}"))
          (quiet "true"))
        (loop (jinja "{{ _minimal_data_needed }}"))
        (loop_control 
          (label (jinja "{{ item.0 }}") ":" (jinja "{{ item.1.key }}"))))
      (task "Check all checksums are sorted by version"
        (assert 
          (that "actual == sorted")
          (quiet "true")
          (msg (jinja "{{ actual | ansible.utils.fact_diff(sorted) }}")))
        (vars 
          (actual (jinja "{{ item.1.value.keys() | map('string') | reverse}}"))
          (sorted (jinja "{{ item.1.value.keys() | map('string') | community.general.version_sort }}")))
        (loop (jinja "{{ _minimal_data_needed }}"))
        (loop_control 
          (label (jinja "{{ item.0 }}") ":" (jinja "{{ item.1.key }}")))
        (when (list
            "item.1.value is not string"
            "(item.1.value | dict2items)[0].value is string or (item.1.value | dict2items)[0].value is number")))
      (task "Include the packages list variable"
        (include_vars "../roles/system_packages/vars/main.yml"))
      (task "Verify that the packages list is sorted"
        (assert 
          (that "pkgs_lists | sort == pkgs_lists")
          (fail_msg (jinja "{{ item }}") " is not sorted: " (jinja "{{ pkgs_lists | ansible.utils.fact_diff(pkgs_lists | sort) }}")))
        (loop (list
            "pkgs_to_remove"
            "pkgs"))
        (vars 
          (pkgs_lists (jinja "{{ lookup('vars', item).keys() | list }}"))
          (ansible_distribution "irrelevant")
          (ansible_distribution_major_version "irrelevant")
          (ansible_distribution_minor_version "irrelevant")
          (ansible_distribution_version "1.0")
          (ansible_os_family "irrelevant"))))))
