(playbook "kubespray/tests/testcases/010_check-apiserver.yml"
  (tasks
    (task "Check the API servers are responding"
      (uri 
        (url "https://" (jinja "{{ (access_ip if (ipv4_stack | default(true)) else access_ip6) | default(ansible_default_ipv4.address if (ipv4_stack | default(true)) else ansible_default_ipv6.address) | ansible.utils.ipwrap }}") ":" (jinja "{{ kube_apiserver_port | default(6443) }}") "/version")
        (validate_certs "false")
        (status_code "200"))
      (register "apiserver_response")
      (retries "12")
      (delay "5")
      (until "apiserver_response is success"))
    (task "Check API servers version"
      (assert 
        (that (list
            "apiserver_response.json.gitVersion == ('v' + kube_version)"))
        (fail_msg "apiserver is " (jinja "{{ apiserver_response.json.gitVersion }}") ", expected " (jinja "{{ kube_version }}"))))))
