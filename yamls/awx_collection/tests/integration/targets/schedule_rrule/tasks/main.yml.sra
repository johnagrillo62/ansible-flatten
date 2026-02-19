(playbook "awx_collection/tests/integration/targets/schedule_rrule/tasks/main.yml"
  (tasks
    (task "Get our collection package"
      (awx.awx.controller_meta null)
      (register "controller_meta"))
    (task "Generate the name of our plugin"
      (ansible.builtin.set_fact 
        (plugin_name (jinja "{{ controller_meta.prefix }}") ".schedule_rrule")))
    (task "Lookup with too many parameters (should fail)"
      (ansible.builtin.set_fact 
        (_rrule (jinja "{{ query(plugin_name, days_of_week=[1, 2], days_of_month=[15]) }}")))
      (register "result_too_many_params")
      (ignore_errors "true"))
    (task "Assert proper error is reported for too many parameters"
      (ansible.builtin.assert 
        (that (list
            "result_too_many_params.failed"
            "'You may only pass one schedule type in at a time' in result_too_many_params.msg"))))
    (task "Attempt invalid schedule_rrule lookup with bad frequency"
      (ansible.builtin.debug 
        (msg (jinja "{{ lookup(plugin_name, 'john', start_date='2020-04-16 03:45:07') }}")))
      (register "result_bad_freq")
      (ignore_errors "true"))
    (task "Assert proper error is reported for bad frequency"
      (ansible.builtin.assert 
        (that (list
            "result_bad_freq.failed"
            "'Frequency of john is invalid' in result_bad_freq.msg | default('')"))))
    (task "Test an invalid start date"
      (ansible.builtin.debug 
        (msg (jinja "{{ lookup(plugin_name, 'none', start_date='invalid') }}")))
      (register "result_bad_date")
      (ignore_errors "true"))
    (task "Assert plugin error message for invalid start date"
      (ansible.builtin.assert 
        (that (list
            "result_bad_date.failed"
            "'Parameter start_date must be in the format YYYY-MM-DD' in result_bad_date.msg | default('')"))))
    (task "Test end_on as count (generic success case)"
      (ansible.builtin.debug 
        (msg (jinja "{{ lookup(plugin_name, 'minute', start_date='2020-4-16 03:45:07', end_on='2') }}")))
      (register "result_success"))
    (task "Assert successful rrule generation"
      (ansible.builtin.assert 
        (that (list
            "result_success.msg == 'DTSTART;TZID=America/New_York:20200416T034507 RRULE:FREQ=MINUTELY;COUNT=2;INTERVAL=1'"))))))
