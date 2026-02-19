(playbook "debops/ansible/roles/apt_mirror/defaults/main.yml"
  (apt_mirror__base_packages (list
      "apt-mirror"))
  (apt_mirror__packages (list))
  (apt_mirror__cron_environment )
  (apt_mirror__cron_time "0 4	* * *")
  (apt_mirror__user "apt-mirror")
  (apt_mirror__group "apt-mirror")
  (apt_mirror__fqdn (jinja "{{ ansible_fqdn }}"))
  (apt_mirror__web_root "/var/spool/apt-mirror/mirror")
  (apt_mirror__default_options (list
      
      (name "base_path")
      (value "/var/spool/apt-mirror")
      (state "comment")
      
      (name "mirror_path")
      (value "$base_path/mirror")
      (state "comment")
      
      (name "skel_path")
      (value "$base_path/skel")
      (state "comment")
      
      (name "var_path")
      (value "$base_path/var")
      (state "dynamic")
      
      (name "cleanscript")
      (value "$var_path/clean.sh")
      (state "comment")
      
      (name "defaultarch")
      (value "<running host architecture>")
      (state "comment")
      
      (name "postmirror_script")
      (value "$var_path/postmirror.sh")
      (state "comment")
      
      (name "run_postmirror")
      (value "0")
      (state "comment")
      
      (name "nthreads")
      (value "20")
      
      (name "_tilde")
      (value "0")))
  (apt_mirror__default_configuration (list
      
      (name "default")
      (filename "mirror.list")
      (sources (list
          
          (name "debian-stable")
          (type "deb")
          (uri "http://deb.debian.org/debian")
          (suite "stable")
          (components (list
              "main"
              "contrib"
              "non-free"))
          (state "comment")
          
          (name "debian-stable-src")
          (raw "deb-src http://deb.debian.org/debian stable main contrib non-free")
          (state "comment")
          
          (name "clean-debian")
          (comment "Generate a clean.sh script for Debian mirror")
          (type "clean")
          (uri "http://deb.debian.org/debian")
          (weight "1000")))))
  (apt_mirror__configuration (list))
  (apt_mirror__group_configuration (list))
  (apt_mirror__host_configuration (list))
  (apt_mirror__combined_configuration (jinja "{{ apt_mirror__default_configuration
                                        + apt_mirror__configuration
                                        + apt_mirror__group_configuration
                                        + apt_mirror__host_configuration }}"))
  (apt_mirror__nginx__dependent_servers (list
      
      (by_role "debops.apt_mirror")
      (enabled "True")
      (ssl "False")
      (filename "debops.apt_mirror_http")
      (name (jinja "{{ apt_mirror__fqdn }}"))
      (root (jinja "{{ apt_mirror__web_root }}"))
      (webroot_create "False")
      (location 
        (/ "try_files $uri $uri/ $uri.html /index.html =404;
autoindex on;
"))
      (state "present")
      
      (by_role "debops.apt_mirror")
      (enabled "True")
      (listen "False")
      (filename "debops.apt_mirror_https")
      (name (jinja "{{ apt_mirror__fqdn }}"))
      (root (jinja "{{ apt_mirror__web_root }}"))
      (webroot_create "False")
      (location 
        (/ "try_files $uri $uri/ $uri.html /index.html =404;
autoindex on;
"))
      (state (jinja "{{ \"present\" if (ansible_local.pki.enabled | d()) | bool else \"absent\" }}")))))
