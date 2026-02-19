(playbook "debops/ansible/roles/memcached/defaults/main.yml"
  (memcached__base_packages (list
      "memcached"))
  (memcached__packages (list))
  (memcached__version (jinja "{{ ansible_local.memcached.version | d(\"0.0.0\") }}"))
  (memcached__bind "127.0.0.1")
  (memcached__allow (list))
  (memcached__memory (jinja "{{ (memcached__memory_available | float *
                        memcached__memory_multiplier | float) | int }}"))
  (memcached__memory_available (jinja "{{ ansible_memtotal_mb }}"))
  (memcached__memory_multiplier "0.3")
  (memcached__connections "1024")
  (memcached__options "")
  (memcached__etc_services__dependent_list (list
      
      (name "memcache")
      (port "11211")))
  (memcached__ferm__dependent_rules (list
      
      (type "accept")
      (dport (list
          "memcache"))
      (protocol (list
          "tcp"
          "udp"))
      (saddr (jinja "{{ memcached__allow }}"))
      (accept_any "False")
      (weight "50")
      (role "memcached"))))
