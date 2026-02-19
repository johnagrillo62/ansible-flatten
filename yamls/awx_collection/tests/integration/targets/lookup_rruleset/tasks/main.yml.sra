(playbook "awx_collection/tests/integration/targets/lookup_rruleset/tasks/main.yml"
  (tasks
    (task "Get our collection package"
      (controller_meta null)
      (register "controller_meta"))
    (task "Generate the name of our plugin"
      (set_fact 
        (ruleset_plugin_name (jinja "{{ controller_meta.prefix }}") ".schedule_rruleset")
        (rule_plugin_name (jinja "{{ controller_meta.prefix }}") ".schedule_rrule")))
    (task "Call ruleset with no rules"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name | string, '2022-04-30 10:30:45') }}")))
      (ignore_errors "True")
      (register "results"))
    (task
      (assert 
        (that (list
            "results is failed"
            "'You must include rules to be in the ruleset via the rules parameter' in results.msg"))))
    (task "call ruleset with a missing frequency"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            
            (interval "1")
            (byweekday "sunday")))))
    (task
      (assert 
        (that (list
            "results is failed"
            "'Rule 2 is missing a frequency' in results.msg"))))
    (task "call ruleset with a missing frequency"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            
            (interval "1")
            (byweekday "sunday")))))
    (task
      (assert 
        (that (list
            "results is failed"
            "'Rule 2 is missing a frequency' in results.msg"))))
    (task "call rruleset with an invalid frequency"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            
            (frequency "asdf")
            (interval "1")
            (byweekday "sunday")))))
    (task
      (assert 
        (that (list
            "results is failed"
            "'Frequency of rule 2 is invalid asdf' in results.msg"))))
    (task "call rruleset with an invalid end_on"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            
            (frequency "day")
            (interval "1")
            (byweekday "sunday")
            (end_on "a")))))
    (task
      (assert 
        (that (list
            "results is failed"
            "'In rule 2 end_on must either be an integer or in the format YYYY-MM-DD [HH:MM:SS]' in results.msg"))))
    (task "Every Mondays"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules, timezone='UTC' ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            (byweekday "monday")))))
    (task
      (assert 
        (that (list
            "results is success"
            "'DTSTART;TZID=UTC:20220430T103045 RRULE:FREQ=DAILY;BYDAY=MO;INTERVAL=1' == complex_rule"))))
    (task "call rruleset with an invalid byweekday"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            
            (frequency "day")
            (interval "1")
            (byweekday "junk")))))
    (task
      (assert 
        (that (list
            "results is failed"
            "'In rule 2 byweekday must only contain values' in results.msg"))))
    (task "call rruleset with a monthly rule with invalid bymonthday (a)"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            
            (frequency "month")
            (interval "1")
            (bymonthday "a")))))
    (task
      (assert 
        (that (list
            "results is failed"
            "'In rule 2 bymonthday must be between 1 and 31' in results.msg"))))
    (task "call rruleset with a monthly rule with invalid bymonthday (-1)"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            
            (frequency "month")
            (interval "1")
            (bymonthday "-1")))))
    (task
      (assert 
        (that (list
            "results is failed"
            "'In rule 2 bymonthday must be between 1 and 31' in results.msg"))))
    (task "call rruleset with a monthly rule with invalid bymonthday (32)"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            
            (frequency "month")
            (interval "1")
            (bymonthday "32")))))
    (task
      (assert 
        (that (list
            "results is failed"
            "'In rule 2 bymonthday must be between 1 and 31' in results.msg"))))
    (task "call rruleset with a monthly rule with invalid bysetpos (junk)"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            
            (frequency "month")
            (interval "1")
            (bysetpos "junk")))))
    (task
      (assert 
        (that (list
            "results is failed"
            "'In rule 2 bysetpos must only contain values in first, second, third, fourth, last' in results.msg"))))
    (task "call rruleset with an invalid timezone"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules, timezone='junk' ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            
            (frequency "day")
            (interval "1")
            (byweekday "sunday")))))
    (task
      (assert 
        (that (list
            "results is failed"
            "'Timezone parameter is not valid' in results.msg"))))
    (task "call rruleset with only exclude rules"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            (include "False")
            
            (frequency "day")
            (interval "1")
            (byweekday "sunday")
            (include "False")))))
    (task
      (assert 
        (that (list
            "results is failed"
            "'A ruleset must contain at least one RRULE' in results.msg"))))
    (task "Every day except for Sundays"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules, timezone='UTC' ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            
            (frequency "day")
            (interval "1")
            (byweekday "sunday")
            (include "False")))))
    (task
      (assert 
        (that (list
            "results is success"
            "'DTSTART;TZID=UTC:20220430T103045 RRULE:FREQ=DAILY;INTERVAL=1 EXRULE:FREQ=DAILY;BYDAY=SU;INTERVAL=1' == complex_rule"))))
    (task "Every day except for April 30th"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2023-04-28 17:00:00', rules=rrules, timezone='UTC' ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            
            (frequency "day")
            (interval "1")
            (bymonth "4")
            (bymonthday "30")
            (include "False")))))
    (task
      (assert 
        (that (list
            "results is success"
            "'DTSTART;TZID=UTC:20230428T170000 RRULE:FREQ=DAILY;INTERVAL=1 EXRULE:FREQ=DAILY;BYMONTH=4;BYMONTHDAY=30;INTERVAL=1' == complex_rule"))))
    (task "Every 5 minutes but not on Mondays from 5-7pm"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules, timezone='UTC' ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "minute")
            (interval "5")
            
            (frequency "minute")
            (interval "5")
            (byweekday "monday")
            (byhour (list
                "17"
                "18"))
            (include "False")))))
    (task
      (assert 
        (that (list
            "results is success"
            "'DTSTART;TZID=UTC:20220430T103045 RRULE:FREQ=MINUTELY;INTERVAL=5 EXRULE:FREQ=MINUTELY;INTERVAL=5;BYDAY=MO;BYHOUR=17,18' == complex_rule"))))
    (task "Every 15 minutes Monday to Friday from 10:01am to 6:02pm (inclusive)"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules, timezone='UTC' ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "minute")
            (byweekday (list
                "monday"
                "tuesday"
                "wednesday"
                "thursday"
                "friday"))
            (interval "15")
            (byhour (list
                "10"
                "11"
                "12"
                "13"
                "14"
                "15"
                "16"
                "17"
                "18"))
            
            (frequency "minute")
            (interval "1")
            (byweekday "monday,tuesday,wednesday, thursday,friday")
            (byhour "18")
            (byminute (jinja "{{ range(3, 60) | list }}"))
            (include "False")))))
    (task
      (assert 
        (that (list
            "results is success"
            "'DTSTART;TZID=UTC:20220430T103045 RRULE:FREQ=MINUTELY;INTERVAL=15;BYDAY=MO,TU,WE,TH,FR;BYHOUR=10,11,12,13,14,15,16,17,18 EXRULE:FREQ=MINUTELY;BYDAY=MO,TU,WE,TH,FR;BYHOUR=18;BYMINUTE=3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59;INTERVAL=1' == complex_rule"))))
    (task "Any Saturday whose month day is between 12 and 18"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules, timezone='UTC' ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "month")
            (interval "1")
            (byweekday "saturday")
            (bymonthday (jinja "{{ range(12,19) | list }}"))))))
    (task
      (assert 
        (that (list
            "results is success"
            "'DTSTART;TZID=UTC:20220430T103045 RRULE:FREQ=MONTHLY;BYMONTHDAY=12,13,14,15,16,17,18;BYDAY=SA;INTERVAL=1' == complex_rule"))))
    (task "mondays, Tuesdays, and WEDNESDAY with case-insensitivity"
      (set_fact 
        (complex_rule (jinja "{{ lookup(ruleset_plugin_name, '2022-04-30 10:30:45', rules=rrules, timezone='UTC' ) }}")))
      (ignore_errors "True")
      (register "results")
      (vars 
        (rrules (list
            
            (frequency "day")
            (interval "1")
            (byweekday "monday, Tuesday, WEDNESDAY")))))
    (task
      (assert 
        (that (list
            "results is success"
            "'DTSTART;TZID=UTC:20220430T103045 RRULE:FREQ=DAILY;BYDAY=MO,TU,WE;INTERVAL=1' == complex_rule"))))))
