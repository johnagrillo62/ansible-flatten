(playbook "kubespray/tests/testcases/020_check-pods-running.yml"
  (tasks
    (task
      (import_role 
        (name "cluster-dump")))
    (task "Check kubectl output"
      (command (jinja "{{ bin_dir }}") "/kubectl get pods --all-namespaces -owide")
      (changed_when "false"))
    (task "Check pods"
      (block (list
          
          (name "Check that all pods are running")
          (command (jinja "{{ bin_dir }}") "/kubectl get pods --all-namespaces -o json")
          (register "run_pods_log")
          (changed_when "false")
          (until (list
              "run_pods_log.stdout | from_json | json_query(query_pods_not_running) == []"
              "run_pods_log.stdout | from_json | json_query(query_pods_not_ready) == []"))
          (retries "30")
          (delay "10")))
      (rescue (list
          
          (name "Describe broken pods")
          (command (jinja "{{ bin_dir }}") "/kubectl describe pod -n " (jinja "{{ item.namespace }}") " " (jinja "{{ item.name }}"))
          (loop (jinja "{{ pods_not_running + pods_not_ready }}"))
          (loop_control 
            (label (jinja "{{ item.namespace }}") "/" (jinja "{{ item.name }}")))
          
          (name "Get logs from broken pods")
          (command (jinja "{{ bin_dir }}") "/kubectl logs -n " (jinja "{{ item.namespace }}") " " (jinja "{{ item.name }}"))
          (loop (jinja "{{ pods_not_running + pods_not_ready }}"))
          (loop_control 
            (label (jinja "{{ item.namespace }}") "/" (jinja "{{ item.name }}")))
          
          (name "Fail CI")
          (fail )))
      (vars 
        (query_pods_not_running "items[?status.phase != 'Running']")
        (query_pods_not_ready "items[?(status.conditions[?type == 'Ready'])[0].status != 'True']")
        (pods_not_running (jinja "{{ run_pods_log.stdout | from_json | json_query(query_pods_not_running + '.metadata') }}"))
        (pods_not_ready (jinja "{{ run_pods_log.stdout | from_json | json_query(query_pods_not_ready + '.metadata') }}"))))))
