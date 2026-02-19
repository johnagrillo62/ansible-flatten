(playbook "kubespray/roles/bootstrap_os/tasks/opensuse.yml"
  (tasks
    (task "Gather host facts to get ansible_distribution_version ansible_distribution_major_version"
      (setup 
        (gather_subset "!all")
        (filter "ansible_distribution_*version")))
    (task "Check that /etc/sysconfig/proxy file exists"
      (stat 
        (path "/etc/sysconfig/proxy")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "stat_result"))
    (task "Create the /etc/sysconfig/proxy empty file"
      (file 
        (path "/etc/sysconfig/proxy")
        (state "touch"))
      (when (list
          "http_proxy is defined or https_proxy is defined"
          "not stat_result.stat.exists")))
    (task "Set the http_proxy in /etc/sysconfig/proxy"
      (lineinfile 
        (path "/etc/sysconfig/proxy")
        (regexp "^HTTP_PROXY=")
        (line "HTTP_PROXY=\"" (jinja "{{ http_proxy }}") "\""))
      (become "true")
      (when (list
          "http_proxy is defined")))
    (task "Set the https_proxy in /etc/sysconfig/proxy"
      (lineinfile 
        (path "/etc/sysconfig/proxy")
        (regexp "^HTTPS_PROXY=")
        (line "HTTPS_PROXY=\"" (jinja "{{ https_proxy }}") "\""))
      (become "true")
      (when (list
          "https_proxy is defined")))
    (task "Enable proxies"
      (lineinfile 
        (path "/etc/sysconfig/proxy")
        (regexp "^PROXY_ENABLED=")
        (line "PROXY_ENABLED=\"yes\""))
      (become "true")
      (when (list
          "http_proxy is defined or https_proxy is defined")))
    (task "Install python-xml"
      (shell "zypper refresh && zypper --non-interactive install python-xml")
      (changed_when "false")
      (become "true")
      (tags (list
          "facts")))))
