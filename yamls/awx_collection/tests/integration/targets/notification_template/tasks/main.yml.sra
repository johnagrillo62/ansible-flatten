(playbook "awx_collection/tests/integration/targets/notification_template/tasks/main.yml"
  (tasks
    (task "Generate a test ID"
      (set_fact 
        (test_id (jinja "{{ lookup('password', '/dev/null chars=ascii_letters length=16') }}")))
      (when "test_id is not defined"))
    (task "Generate names"
      (set_fact 
        (slack_not "AWX-Collection-tests-notification_template-slack-not-" (jinja "{{ test_id }}"))
        (webhook_not "AWX-Collection-tests-notification_template-wehbook-not-" (jinja "{{ test_id }}"))
        (email_not "AWX-Collection-tests-notification_template-email-not-" (jinja "{{ test_id }}"))
        (twillo_not "AWX-Collection-tests-notification_template-twillo-not-" (jinja "{{ test_id }}"))
        (pd_not "AWX-Collection-tests-notification_template-pd-not-" (jinja "{{ test_id }}"))
        (irc_not "AWX-Collection-tests-notification_template-irc-not-" (jinja "{{ test_id }}"))))
    (task "Create Slack notification with custom messages"
      (notification_template 
        (name (jinja "{{ slack_not }}"))
        (organization "Default")
        (notification_type "slack")
        (notification_configuration 
          (token "a_token")
          (channels (list
              "general")))
        (messages 
          (started 
            (message (jinja "{{ '{{' }}") " job_friendly_name " (jinja "{{' }}' }}") " " (jinja "{{ '{{' }}") " job.id " (jinja "{{' }}' }}") " started"))
          (success 
            (message (jinja "{{ '{{' }}") " job_friendly_name " (jinja "{{ '}}' }}") " completed in " (jinja "{{ '{{' }}") " job.elapsed " (jinja "{{ '}}' }}") " seconds"))
          (error 
            (message (jinja "{{ '{{' }}") " job_friendly_name " (jinja "{{ '}}' }}") " FAILED! Please look at " (jinja "{{ '{{' }}") " job.url " (jinja "{{ '}}' }}"))))
        (state "present"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create Slack notification with custom messages with exists"
      (notification_template 
        (name (jinja "{{ slack_not }}"))
        (organization "Default")
        (notification_type "slack")
        (notification_configuration 
          (token "a_token")
          (channels (list
              "general")))
        (messages 
          (started 
            (message (jinja "{{ '{{' }}") " job_friendly_name " (jinja "{{' }}' }}") " " (jinja "{{ '{{' }}") " job.id " (jinja "{{' }}' }}") " started"))
          (success 
            (message (jinja "{{ '{{' }}") " job_friendly_name " (jinja "{{ '}}' }}") " completed in " (jinja "{{ '{{' }}") " job.elapsed " (jinja "{{ '}}' }}") " seconds"))
          (error 
            (message (jinja "{{ '{{' }}") " job_friendly_name " (jinja "{{ '}}' }}") " FAILED! Please look at " (jinja "{{ '{{' }}") " job.url " (jinja "{{ '}}' }}"))))
        (state "exists"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is not changed"))))
    (task "Delete Slack notification with custom messages"
      (notification_template 
        (name (jinja "{{ slack_not }}"))
        (organization "Default")
        (notification_type "slack")
        (notification_configuration 
          (token "a_token")
          (channels (list
              "general")))
        (messages 
          (started 
            (message (jinja "{{ '{{' }}") " job_friendly_name " (jinja "{{' }}' }}") " " (jinja "{{ '{{' }}") " job.id " (jinja "{{' }}' }}") " started"))
          (success 
            (message (jinja "{{ '{{' }}") " job_friendly_name " (jinja "{{ '}}' }}") " completed in " (jinja "{{ '{{' }}") " job.elapsed " (jinja "{{ '}}' }}") " seconds"))
          (error 
            (message (jinja "{{ '{{' }}") " job_friendly_name " (jinja "{{ '}}' }}") " FAILED! Please look at " (jinja "{{ '{{' }}") " job.url " (jinja "{{ '}}' }}"))))
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Create Slack notification with custom messages with exists"
      (notification_template 
        (name (jinja "{{ slack_not }}"))
        (organization "Default")
        (notification_type "slack")
        (notification_configuration 
          (token "a_token")
          (channels (list
              "general")))
        (messages 
          (started 
            (message (jinja "{{ '{{' }}") " job_friendly_name " (jinja "{{' }}' }}") " " (jinja "{{ '{{' }}") " job.id " (jinja "{{' }}' }}") " started"))
          (success 
            (message (jinja "{{ '{{' }}") " job_friendly_name " (jinja "{{ '}}' }}") " completed in " (jinja "{{ '{{' }}") " job.elapsed " (jinja "{{ '}}' }}") " seconds"))
          (error 
            (message (jinja "{{ '{{' }}") " job_friendly_name " (jinja "{{ '}}' }}") " FAILED! Please look at " (jinja "{{ '{{' }}") " job.url " (jinja "{{ '}}' }}"))))
        (state "exists"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete Slack notification"
      (notification_template 
        (name (jinja "{{ slack_not }}"))
        (organization "Default")
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Add webhook notification"
      (notification_template 
        (name (jinja "{{ webhook_not }}"))
        (organization "Default")
        (notification_type "webhook")
        (notification_configuration 
          (url "http://www.example.com/hook")
          (headers 
            (X-Custom-Header "value123")))
        (state "present"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete webhook notification"
      (notification_template 
        (name (jinja "{{ webhook_not }}"))
        (organization "Default")
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Add email notification"
      (notification_template 
        (name (jinja "{{ email_not }}"))
        (organization "Default")
        (notification_type "email")
        (notification_configuration 
          (username "user")
          (password "s3cr3t")
          (sender "tower@example.com")
          (recipients (list
              "user1@example.com"))
          (host "smtp.example.com")
          (port "25")
          (use_tls "false")
          (use_ssl "false"))
        (state "present"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Copy email notification"
      (notification_template 
        (name "copy_" (jinja "{{ email_not }}"))
        (copy_from (jinja "{{ email_not }}"))
        (organization "Default"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result.copied"))))
    (task "Delete copied email notification"
      (notification_template 
        (name "copy_" (jinja "{{ email_not }}"))
        (organization "Default")
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete email notification"
      (notification_template 
        (name (jinja "{{ email_not }}"))
        (organization "Default")
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Add twilio notification"
      (notification_template 
        (name (jinja "{{ twillo_not }}"))
        (organization "Default")
        (notification_type "twilio")
        (notification_configuration 
          (account_token "a_token")
          (account_sid "a_sid")
          (from_number "+15551112222")
          (to_numbers (list
              "+15553334444")))
        (state "present"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete twilio notification"
      (notification_template 
        (name (jinja "{{ twillo_not }}"))
        (organization "Default")
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Add PagerDuty notification"
      (notification_template 
        (name (jinja "{{ pd_not }}"))
        (organization "Default")
        (notification_type "pagerduty")
        (notification_configuration 
          (token "a_token")
          (subdomain "sub")
          (client_name "client")
          (service_key "a_key"))
        (state "present"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete PagerDuty notification"
      (notification_template 
        (name (jinja "{{ pd_not }}"))
        (organization "Default")
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Add IRC notification"
      (notification_template 
        (name (jinja "{{ irc_not }}"))
        (organization "Default")
        (notification_type "irc")
        (notification_configuration 
          (nickname "tower")
          (password "s3cr3t")
          (targets (list
              "user1"))
          (port "8080")
          (server "irc.example.com")
          (use_ssl "false"))
        (state "present"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))
    (task "Delete IRC notification"
      (notification_template 
        (name (jinja "{{ irc_not }}"))
        (organization "Default")
        (state "absent"))
      (register "result"))
    (task
      (assert 
        (that (list
            "result is changed"))))))
