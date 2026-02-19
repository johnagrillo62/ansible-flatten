(playbook "debops/ansible/roles/fhs/defaults/main.yml"
  (fhs__enabled "True")
  (fhs__default_directories (list
      
      (name "facts")
      (path "/etc/ansible/facts.d")
      
      (name "bin")
      (path "/usr/local/bin")
      
      (name "etc")
      (path "/usr/local/etc")
      
      (name "lib")
      (path "/usr/local/lib")
      
      (name "sbin")
      (path "/usr/local/sbin")
      
      (name "share")
      (path "/usr/local/share")
      
      (name "src")
      (path "/usr/local/src")
      
      (name "data")
      (path "/srv")
      
      (name "srv")
      (path "/srv")
      
      (name "www")
      (path "/srv/www")
      
      (name "backup")
      (path "/var/backups")
      
      (name "home")
      (path "/var/local")
      (mode "02775")
      
      (name "var")
      (path "/var/local")
      (mode "02775")
      
      (name "app")
      (path "/var/local")
      (mode "02775")
      
      (name "cache")
      (path "/var/cache")
      
      (name "log")
      (path "/var/log")
      (mode (jinja "{{ \"u=rwX,g=rwX,o=rX\"
              if (ansible_distribution in [\"Ubuntu\", \"Linux Mint\"])
              else omit }}"))
      
      (name "spool")
      (path "/var/spool")))
  (fhs__directories (list))
  (fhs__group_directories (list))
  (fhs__host_directories (list))
  (fhs__combined_directories (jinja "{{ fhs__default_directories
                               + fhs__directories
                               + fhs__group_directories
                               + fhs__host_directories }}")))
