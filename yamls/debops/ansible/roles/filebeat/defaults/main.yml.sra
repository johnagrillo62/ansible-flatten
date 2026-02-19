(playbook "debops/ansible/roles/filebeat/defaults/main.yml"
  (filebeat__base_packages (list
      "filebeat"))
  (filebeat__packages (list))
  (filebeat__version (jinja "{{ ansible_local.filebeat.version | d(\"0.0.0\") }}"))
  (filebeat__original_configuration (list
      
      (name "filebeat_inputs")
      (config 
        (filebeat.inputs (list
            
            (type "log")
            (enabled "False")
            (paths (list
                "/var/log/*.log")))))
      
      (name "filebeat_config_modules")
      (config 
        (filebeat.config.modules 
          (path "${path.config}/modules.d/*.yml")
          (reload.enabled "False")))
      
      (name "setup_template_settings")
      (config 
        (setup.template.settings 
          (index.number_of_shards "3")))
      
      (name "setup_kibana")
      (config 
        (setup.kibana null))
      
      (name "output_elasticsearch")
      (config 
        (output.elasticsearch 
          (hosts (list
              "localhost:9200"))))
      
      (name "processors")
      (config 
        (processors (list
            
            (add_host_metadata null)
            
            (add_cloud_metadata null))))))
  (filebeat__default_configuration (list
      
      (name "filebeat_inputs")
      (config 
        (filebeat.inputs (list
            
            (type "log")
            (enabled "True")
            (paths (list
                "/var/log/*.log"
                "/var/log/messages")))))
      
      (name "filebeat_config_inputs")
      (config 
        (filebeat.config.inputs 
          (path "${path.config}/inputs.d/*.yml")
          (reload.enabled "True")
          (reload.period "30s")))
      
      (name "filebeat_config_modules")
      (config 
        (filebeat.config.modules 
          (path "${path.config}/modules.d/*.yml")
          (reload.enabled "True")
          (reload.period "30s")))))
  (filebeat__configuration (list))
  (filebeat__group_configuration (list))
  (filebeat__host_configuration (list))
  (filebeat__combined_configuration (jinja "{{ filebeat__original_configuration
                                      + filebeat__default_configuration
                                      + filebeat__configuration
                                      + filebeat__group_configuration
                                      + filebeat__host_configuration }}"))
  (filebeat__default_snippets (list
      
      (name "inputs.d/ceph.yml")
      (state (jinja "{{ \"present\"
               if ansible_local.ceph.installed | d() | bool
               else \"absent\" }}"))
      (config (list
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/ceph/ceph-osd.*.log"))
          (ignore_older "1h")
          (fields 
            (ceph.daemon "osd"))
          (fields_under_root "True")
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/ceph/ceph-mgr.*.log"))
          (ignore_older "1h")
          (fields 
            (ceph.daemon "mgr"))
          (fields_under_root "True")
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/ceph/ceph-mon.*.log"))
          (ignore_older "1h")
          (fields 
            (ceph.daemon "mon"))
          (fields_under_root "True")
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/ceph/ceph.log"))
          (ignore_older "1h")
          (fields 
            (ceph.daemon "ceph"))
          (fields_under_root "True")
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/ceph/ceph.audit.log"))
          (ignore_older "1h")
          (fields 
            (ceph.daemon "audit"))
          (fields_under_root "True")))
      
      (name "inputs.d/libvirt.yml")
      (state (jinja "{{ \"present\"
               if ansible_local.libvirtd.installed | d() | bool
               else \"absent\" }}"))
      (config 
        (type "log")
        (enabled "True")
        (paths (list
            "/var/log/libvirt/*.log"
            "/var/log/libvirt/qemu/*.log"))
        (ignore_older "1h")
        (fields 
          (libvirt "True"))
        (fields_under_root "True"))
      
      (name "inputs.d/named.yml")
      (state (jinja "{{ \"present\"
               if ansible_local.bind.installed | d() | bool
               else \"absent\" }}"))
      (config (list
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/named/named.log"))
          (ignore_older "1h")
          (fields 
            (named.type "general"))
          (files_under_root "True")
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/named/lame.log"))
          (ignore_older "1h")
          (fields 
            (named.type "lame"))
          (files_under_root "True")
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/named/query.log"))
          (ignore_older "1h")
          (fields 
            (named.type "query"))
          (files_under_root "True")
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/named/query-errors.log"))
          (ignore_older "1h")
          (fields 
            (named.type "query-errors"))
          (files_under_root "True")))
      
      (name "inputs.d/openstack.yml")
      (state (jinja "{{ \"present\"
               if ansible_local.openstack.installed | d() | bool
               else \"absent\" }}"))
      (config (list
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/nova/*.log"))
          (ignore_older "1h")
          (fields 
            (openstack.component "nova"))
          (fields_under_root "True")
          (multiline 
            (pattern "^.*(ERROR).*[[:space:]]{3}.*")
            (negate "False")
            (match "after"))
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/neutron/*.log"))
          (ignore_older "1h")
          (fields 
            (openstack.component "neutron"))
          (fields_under_root "True")
          (multiline 
            (pattern "^.*(ERROR).*[[:space:]]{3}.*")
            (negate "False")
            (match "after"))
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/glance/*.log"))
          (ignore_older "1h")
          (fields 
            (openstack.component "glance"))
          (fields_under_root "True")
          (multiline 
            (pattern "^.*(ERROR).*[[:space:]]{3}.*")
            (negate "False")
            (match "after"))
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/cinder/*.log"))
          (ignore_older "1h")
          (fields 
            (openstack.component "cinder"))
          (fields_under_root "True")
          (multiline 
            (pattern "^.*(ERROR).*[[:space:]]{3}.*")
            (negate "False")
            (match "after"))
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/keystone/*.log"))
          (ignore_older "1h")
          (fields 
            (openstack.component "keystone"))
          (fields_under_root "True")
          (multiline 
            (pattern "^.*(ERROR).*[[:space:]]{3}.*")
            (negate "False")
            (match "after"))
          
          (type "log")
          (enabled "True")
          (paths (list
              "/var/log/ironic/*.log"
              "/var/log/ironic-inspector/*.log"))
          (ignore_older "1h")
          (fields 
            (openstack.component "ironic"))
          (fields_under_root "True")
          (multiline 
            (pattern "^.*(ERROR).*[[:space:]]{3}.*")
            (negate "False")
            (match "after"))))
      
      (name "modules.d/apache2.yml")
      (config 
        (module "apache2")
        (access 
          (enabled "True"))
        (error 
          (enabled "True")))
      (state (jinja "{{ \"present\"
               if (ansible_local.apache.installed | d() | bool)
               else \"ignore\" }}"))
      
      (name "modules.d/auditd.yml")
      (config 
        (module "auditd")
        (log 
          (enabled "True")))
      (state (jinja "{{ \"present\"
               if (ansible_local.auditd.installed | d() | bool)
               else \"ignore\" }}"))
      
      (name "modules.d/icinga.yml")
      (config 
        (module "icinga")
        (main 
          (enabled "True"))
        (debug 
          (enabled "True"))
        (startup 
          (enabled "True")))
      (state (jinja "{{ \"present\"
               if (ansible_local.icinga.installed | d() | bool)
               else \"ignore\" }}"))
      
      (name "modules.d/mysql.yml")
      (config 
        (module "mysql")
        (error 
          (enabled "True"))
        (slowlog 
          (enabled "True")))
      (state (jinja "{{ \"present\"
               if (ansible_local.mariadb.installed | d() | bool)
               else \"ignore\" }}"))
      
      (name "modules.d/nginx.yml")
      (config 
        (module "nginx")
        (access 
          (enabled "True"))
        (error 
          (enabled "True")))
      (state (jinja "{{ \"present\"
               if (ansible_local.nginx.installed | d() | bool)
               else \"ignore\" }}"))
      
      (name "modules.d/postgresql.yml")
      (config 
        (module "postgresql")
        (log 
          (enabled "True")))
      (state (jinja "{{ \"present\"
               if (ansible_local.postgresql.installed | d() | bool)
               else \"ignore\" }}"))
      
      (name "modules.d/system.yml")
      (config 
        (module "system")
        (syslog 
          (enabled "True"))
        (auth 
          (enabled "True")))))
  (filebeat__snippets (list))
  (filebeat__group_snippets (list))
  (filebeat__host_snippets (list))
  (filebeat__combined_snippets (jinja "{{ filebeat__default_snippets
                                 + filebeat__snippets
                                 + filebeat__group_snippets
                                 + filebeat__host_snippets }}"))
  (filebeat__keys (list))
  (filebeat__group_keys (list))
  (filebeat__host_keys (list))
  (filebeat__combined_keys (jinja "{{ filebeat__keys
                             + filebeat__group_keys
                             + filebeat__host_keys }}"))
  (filebeat__extrepo__dependent_sources (list
      "elastic")))
