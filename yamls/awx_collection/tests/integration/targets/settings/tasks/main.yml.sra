(playbook "awx_collection/tests/integration/targets/settings/tasks/main.yml"
  (tasks
    (task "Initialize starting project vvv setting to false"
      (awx.awx.settings 
        (name "PROJECT_UPDATE_VVV")
        (value "false")))
    (task "Change project vvv setting to true"
      (awx.awx.settings 
        (name "PROJECT_UPDATE_VVV")
        (value "true"))
      (register "result"))
    (task "Changing setting to true should have changed the value"
      (ansible.builtin.assert 
        (that (list
            "result is changed"))))
    (task "Change project vvv setting to true"
      (awx.awx.settings 
        (name "PROJECT_UPDATE_VVV")
        (value "true"))
      (register "result"))
    (task "Changing setting to true again should not change the value"
      (ansible.builtin.assert 
        (that (list
            "result is not changed"))))
    (task "Change project vvv setting back to false"
      (awx.awx.settings 
        (name "PROJECT_UPDATE_VVV")
        (value "false"))
      (register "result"))
    (task "Changing setting back to false should have changed the value"
      (ansible.builtin.assert 
        (that (list
            "result is changed"))))
    (task "Set the value of AWX_ISOLATION_SHOW_PATHS to a baseline"
      (awx.awx.settings 
        (name "AWX_ISOLATION_SHOW_PATHS")
        (value (list
            "/var/lib/awx/projects/"))))
    (task "Set the value of AWX_ISOLATION_SHOW_PATHS to get an error back from the controller"
      (awx.awx.settings 
        (settings 
          (AWX_ISOLATION_SHOW_PATHS 
            (not "a valid")
            (tower "setting"))))
      (register "result")
      (ignore_errors "true"))
    (task "Assert result failed"
      (ansible.builtin.assert 
        (that (list
            "result.failed"
            "'Unable to update settings' in result.msg | default('')"))))
    (task "Set the value of AWX_ISOLATION_SHOW_PATHS"
      (awx.awx.settings 
        (name "AWX_ISOLATION_SHOW_PATHS")
        (value "[\"/var/lib/awx/projects/\", \"/tmp\"]"))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Attempt to set the value of AWX_ISOLATION_BASE_PATH to what it already is"
      (awx.awx.settings 
        (name "AWX_ISOLATION_BASE_PATH")
        (value "/tmp"))
      (register "result"))
    (task "Debug result"
      (ansible.builtin.debug 
        (msg (jinja "{{ result }}"))))
    (task "Result is not changed"
      (ansible.builtin.assert 
        (that (list
            "not (result.changed)"))))
    (task "Apply a single setting via settings"
      (awx.awx.settings 
        (name "AWX_ISOLATION_SHOW_PATHS")
        (value "[\"/var/lib/awx/projects/\", \"/var/tmp\"]"))
      (register "result"))
    (task "Result is changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Apply multiple setting via settings with no change"
      (awx.awx.settings 
        (settings 
          (AWX_ISOLATION_BASE_PATH "/tmp")
          (AWX_ISOLATION_SHOW_PATHS (list
              "/var/lib/awx/projects/"
              "/var/tmp"))))
      (register "result"))
    (task "Debug"
      (ansible.builtin.debug 
        (msg (jinja "{{ result }}"))))
    (task "Assert result is not changed"
      (ansible.builtin.assert 
        (that (list
            "not (result.changed)"))))
    (task "Apply multiple setting via settings with change"
      (awx.awx.settings 
        (settings 
          (AWX_ISOLATION_BASE_PATH "/tmp")
          (AWX_ISOLATION_SHOW_PATHS (list))))
      (register "result"))
    (task "Assert result changed"
      (ansible.builtin.assert 
        (that (list
            "result.changed"))))
    (task "Handle an omit value"
      (awx.awx.settings 
        (name "AWX_ISOLATION_BASE_PATH")
        (value (jinja "{{ junk_var | default(omit) }}")))
      (register "result")
      (ignore_errors "true"))
    (task "Assert result failed"
      (ansible.builtin.assert 
        (that (list
            "result.failed"
            "'Unable to update settings' in result.msg | default('')"))))))
