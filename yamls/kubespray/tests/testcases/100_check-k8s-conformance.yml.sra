(playbook "kubespray/tests/testcases/100_check-k8s-conformance.yml"
  (tasks
    (task "Download sonobuoy"
      (get_url 
        (url "https://github.com/vmware-tanzu/sonobuoy/releases/download/v" (jinja "{{ sonobuoy_version }}") "/sonobuoy_" (jinja "{{ sonobuoy_version }}") "_linux_" (jinja "{{ sonobuoy_arch }}") ".tar.gz")
        (dest "/tmp/sonobuoy.tar.gz")
        (mode "0644")))
    (task "Extract sonobuoy"
      (unarchive 
        (src "/tmp/sonobuoy.tar.gz")
        (dest "/usr/local/bin/")
        (copy "false")))
    (task "Run sonobuoy"
      (command (jinja "{{ sonobuoy_path }}") " run --mode " (jinja "{{ sonobuoy_mode }}") " --e2e-parallel " (jinja "{{ sonobuoy_parallel }}") " --wait"))
    (task "Run sonobuoy retrieve"
      (command (jinja "{{ sonobuoy_path }}") " retrieve")
      (register "sonobuoy_retrieve"))
    (task "Run inspect results"
      (command (jinja "{{ sonobuoy_path }}") " results " (jinja "{{ sonobuoy_retrieve.stdout }}") " --plugin e2e --mode report"))))
