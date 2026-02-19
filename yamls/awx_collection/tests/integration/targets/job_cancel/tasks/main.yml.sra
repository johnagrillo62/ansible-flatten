(playbook "awx_collection/tests/integration/targets/job_cancel/tasks/main.yml"
  (tasks
    (task "Launch a Job Template"
      (job_launch 
        (job_template "Demo Job Template"))
      (register "job"))
    (task
      (assert 
        (that (list
            "job is changed"))))
    (task "Cancel the job"
      (job_cancel 
        (job_id (jinja "{{ job.id }}"))
        (request_timeout "60"))
      (register "results"))
    (task
      (assert 
        (that (list
            "results is changed"))))
    (task "Cancel an already canceled job (assert failure)"
      (job_cancel 
        (job_id (jinja "{{ job.id }}"))
        (fail_if_not_running "true"))
      (register "results")
      (ignore_errors "yes")
      (until "results is failed and results.msg == 'Job is not running'")
      (retries "6")
      (delay "5"))
    (task "Check module fails with correct msg"
      (job_cancel 
        (job_id "9999999999"))
      (register "result")
      (ignore_errors "yes"))
    (task
      (assert 
        (that (list
            "result.msg =='Unable to cancel job_id/9999999999: The requested object could not be found.' or result.msg =='Unable to find job with id 9999999999'"))))))
