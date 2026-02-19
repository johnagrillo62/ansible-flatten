(playbook "ansible-examples/lamp_haproxy/aws/rolling_update.yml"
    (play
    (hosts "tag_ansible_group_monitoring")
    (tasks))
    (play
    (hosts "tag_ansible_group_webservers")
    (serial "1")
    (pre_tasks
      (task "disable nagios alerts for this host webserver service"
        (nagios "action=disable_alerts host=" (jinja "{{ inventory_hostname }}") " services=webserver")
        (delegate_to (jinja "{{ item }}"))
        (with_items (jinja "{{ groups.tag_ansible_group_monitoring }}")))
      (task "disable the server in haproxy"
        (haproxy "state=disabled backend=myapplb host=" (jinja "{{ inventory_hostname }}") " socket=/var/lib/haproxy/stats")
        (delegate_to (jinja "{{ item }}"))
        (with_items (jinja "{{ groups.tag_ansible_group_lbservers }}"))))
    (roles
      "web")
    (post_tasks
      (task "wait for webserver to come up"
        (wait_for "host=" (jinja "{{ inventory_hostname }}") " port=80 state=started timeout=80"))
      (task "enable the server in haproxy"
        (haproxy "state=enabled backend=myapplb host=" (jinja "{{ inventory_hostname }}") " socket=/var/lib/haproxy/stats")
        (delegate_to (jinja "{{ item }}"))
        (with_items (jinja "{{ groups.tag_ansible_group_lbservers }}")))
      (task "re-enable nagios alerts"
        (nagios "action=enable_alerts host=" (jinja "{{ inventory_hostname }}") " services=webserver")
        (delegate_to (jinja "{{ item }}"))
        (with_items (jinja "{{ groups.tag_ansible_group_monitoring }}"))))))
