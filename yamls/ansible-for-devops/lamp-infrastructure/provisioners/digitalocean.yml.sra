(playbook "ansible-for-devops/lamp-infrastructure/provisioners/digitalocean.yml"
    (play
    (hosts "localhost")
    (connection "local")
    (gather_facts "false")
    (vars
      (droplets (list
          
          (name "a4d.lamp.varnish")
          (group "lamp_varnish")
          
          (name "a4d.lamp.www.1")
          (group "lamp_www")
          
          (name "a4d.lamp.www.2")
          (group "lamp_www")
          
          (name "a4d.lamp.db.1")
          (group "lamp_db")
          
          (name "a4d.lamp.db.2")
          (group "lamp_db")
          
          (name "a4d.lamp.memcached")
          (group "lamp_memcached"))))
    (tasks
      (task "Provision DigitalOcean droplets."
        (digital_ocean_droplet 
          (state (jinja "{{ item.state | default('present') }}"))
          (name (jinja "{{ item.name }}"))
          (private_networking "yes")
          (size (jinja "{{ item.size | default('s-1vcpu-1gb') }}"))
          (image (jinja "{{ item.image | default('centos-7-x64') }}"))
          (region (jinja "{{ item.region | default('nyc3') }}"))
          (ssh_keys (list
              (jinja "{{ item.ssh_key | default('138954') }}")))
          (unique_name "yes"))
        (register "created_droplets")
        (with_items (jinja "{{ droplets }}")))
      (task "Add DigitalOcean hosts to inventory groups."
        (add_host 
          (name (jinja "{{ item.1.data.ip_address }}"))
          (groups "do," (jinja "{{ droplets[item.0].group }}") "," (jinja "{{ item.1.data.droplet.name }}"))
          (ansible_user "root")
          (mysql_replication_role (jinja "{{ 'master' if (item.1.data.droplet.name == 'a4d.lamp.db.1') else 'slave' }}"))
          (mysql_server_id (jinja "{{ item.0 }}")))
        (with_indexed_items (jinja "{{ created_droplets.results }}"))
        (when "item.1.data is defined"))))
    (play
    (hosts "do")
    (remote_user "root")
    (gather_facts "false")
    (tasks
      (task "Wait for hosts to become reachable."
        (wait_for_connection null)))))
