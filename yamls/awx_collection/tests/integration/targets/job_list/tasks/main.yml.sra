(playbook "awx_collection/tests/integration/targets/job_list/tasks/main.yml"
  (tasks
    (task "Launch a Job Template"
      (job_launch 
        (job_template "Demo Job Template"))
      (register "job"))
    (task
      (assert 
        (that (list
            "job is changed"
            "job.status == 'pending'"))))
    (task "List jobs w/ a matching primary key"
      (job_list 
        (query 
          (id (jinja "{{ job.id }}"))))
      (register "matching_jobs"))
    (task
      (assert 
        (that (list
            "matching_jobs.count == 1"))))
    (task "List failed jobs (which don't exist)"
      (job_list 
        (status "failed")
        (query 
          (id (jinja "{{ job.id }}"))))
      (register "successful_jobs"))
    (task
      (assert 
        (that (list
            "successful_jobs.count == 0"))))
    (task "Get ALL result pages!"
      (job_list 
        (all_pages "true"))
      (register "all_page_query"))
    (task
      (assert 
        (that (list
            "not all_page_query.next"))))))
