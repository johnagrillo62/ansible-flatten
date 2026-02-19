(playbook "debops/ansible/roles/minio/defaults/main.yml"
  (minio__user "minio")
  (minio__group "minio")
  (minio__additional_groups (jinja "{{ [\"ssl-cert\"] if minio__pki_enabled | bool else [] }}"))
  (minio__home (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
                 + \"/\" + minio__user }}"))
  (minio__shell "/usr/sbin/nologin")
  (minio__comment "MinIO")
  (minio__upstream_gpg_key "4405 F3F0 DDBA 1B9E 68A3  1D25 12C7 4390 F9AA C728")
  (minio__upstream_type "url")
  (minio__upstream_upgrade "False")
  (minio__upstream_url_mirror "https://dl.min.io/server/minio/release/")
  (minio__upstream_platform "linux-amd64")
  (minio__upstream_url_release (jinja "{{ minio__env_upstream_url_release }}"))
  (minio__upstream_url_binary (jinja "{{ \"archive/minio.\" + minio__upstream_url_release }}"))
  (minio__upstream_git_repository "https://github.com/minio/minio")
  (minio__upstream_git_release (jinja "{{ \"RELEASE.2019-03-27T22-35-21Z\"
                                 if (ansible_distribution_release in
                                     [\"stretch\", \"buster\", \"xenial\", \"bionic\"])
                                     else (\"RELEASE.2019-09-05T23-24-38Z\"
                                       if (ansible_distribution_release in
                                           [\"bullseye\"])
                                       else minio__upstream_url_release) }}"))
  (minio__binary (jinja "{{ ansible_local.golang.binaries[\"minio\"]
                   if (ansible_local.golang.binaries | d() and
                       ansible_local.golang.binaries.minio | d())
                   else \"\" }}"))
  (minio__config_dir "/etc/minio")
  (minio__volumes_dir "/srv/minio")
  (minio__volumes (list))
  (minio__group_volumes (list))
  (minio__host_volumes (list))
  (minio__fqdn (jinja "{{ ansible_fqdn }}"))
  (minio__domain (jinja "{{ ansible_domain }}"))
  (minio__pki_enabled (jinja "{{ ansible_local.pki.enabled
                        if (ansible_local | d() and ansible_local.pki | d() and
                            ansible_local.pki.enabled is defined)
                        else False }}"))
  (minio__pki_base_path (jinja "{{ ansible_local.pki.base_path | d(\"/etc/pki/realms\") }}"))
  (minio__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (minio__pki_key (jinja "{{ ansible_local.pki.key | d(\"default.key\") }}"))
  (minio__pki_crt "public/full.pem")
  (minio__tls_certs_dir (jinja "{{ minio__home + \"/.minio/certs\" }}"))
  (minio__tls_private_key (jinja "{{ minio__pki_base_path + \"/\" + minio__pki_realm + \"/\" + minio__pki_key }}"))
  (minio__tls_public_crt (jinja "{{ minio__pki_base_path + \"/\" + minio__pki_realm + \"/\" + minio__pki_crt }}"))
  (minio__default_instances (list
      
      (name "main")
      (port "9000")
      (console_port "19000")
      (fqdn (jinja "{{ minio__fqdn }}"))
      (domain (jinja "{{ minio__fqdn }}"))))
  (minio__instances (list))
  (minio__group_instances (list))
  (minio__host_instances (list))
  (minio__combined_instances (jinja "{{ minio__default_instances
                               + minio__instances
                               + minio__group_instances
                               + minio__host_instances }}"))
  (minio__golang__dependent_packages (list
      
      (name "minio")
      (upstream_type (jinja "{{ minio__upstream_type }}"))
      (gpg (jinja "{{ minio__upstream_gpg_key }}"))
      (url (list
          
          (src (jinja "{{ minio__upstream_url_mirror + minio__upstream_platform + \"/\" + minio__upstream_url_binary }}"))
          (dest "releases/" (jinja "{{ minio__upstream_platform }}") "/minio/minio." (jinja "{{ minio__upstream_url_release }}"))
          (checksum "sha256:" (jinja "{{ minio__upstream_url_mirror + minio__upstream_platform + \"/\" + minio__upstream_url_binary }}") ".sha256sum")
          
          (src (jinja "{{ minio__upstream_url_mirror + minio__upstream_platform + \"/\" + minio__upstream_url_binary + \".asc\" }}"))
          (dest "releases/" (jinja "{{ minio__upstream_platform }}") "/minio/minio." (jinja "{{ minio__upstream_url_release }}") ".asc")
          (gpg_verify "True")))
      (url_binaries (list
          
          (src "releases/" (jinja "{{ minio__upstream_platform }}") "/minio/minio." (jinja "{{ minio__upstream_url_release }}"))
          (dest "minio")
          (notify "Restart minio")))
      (git (list
          
          (repo (jinja "{{ minio__upstream_git_repository }}"))
          (version (jinja "{{ minio__upstream_git_release }}"))
          (build_script "make clean build
")))
      (git_binaries (list
          
          (src (jinja "{{ minio__upstream_git_repository.split(\"://\")[1] + \"/minio\" }}"))
          (dest "minio")
          (notify "Restart minio")))))
  (minio__etc_services__dependent_list (jinja "{{ minio__env_etc_services_dependent_list }}"))
  (minio__sysctl__dependent_parameters (list
      
      (name "minio")
      (weight "80")
      (options (list
          
          (name "net.ipv4.tcp_fin_timeout")
          (comment "A socket left in memory takes approximately 1.5Kb of memory. It makes
sense to close the unused sockets preemptively to ensure no memory
leakage. This way, even if a peer doesn't close the socket due to
some reason, the system itself closes it after a timeout.

The \"tcp_fin_timeout\" variable defines this timeout and tells kernel
how long to keep sockets in the state FIN-WAIT-2. We recommend
setting it to 30.
")
          (value "30")
          
          (name "net.ipv4.tcp_keepalive_probes")
          (comment "This variable defines the number of unacknowledged probes to be sent
before considering a connection dead.
")
          (value "5")
          
          (name "net.core.wmem_max")
          (comment "This parameter sets the max OS send buffer size for all types of
connections.
")
          (value "540000")
          
          (name "net.core.rmem_max")
          (comment "This parameter sets the max OS receive buffer size for all types of
connections.
")
          (value "540000")
          
          (name "vm.swappiness")
          (comment "This parameter controls the relative weight given to swapping out
runtime memory, as opposed to dropping pages from the system page
cache. It takes values from 0 to 100, both inclusive. We recommend
setting it to 10.
")
          (value "10")
          
          (name "vm.dirty_background_ratio")
          (comment "This is the percentage of system memory that can be filled with dirty
pages, i.e. memory pages that still need to be written to disk. We
recommend writing the data to the disk as soon as possible. To do
this, set the dirty_background_ratio to 1.
")
          (value "1")
          
          (name "vm.dirty_ratio")
          (comment "This defines is the absolute maximum amount of system memory that can
be filled with dirty pages before everything must get committed to
disk.
")
          (value "1")
          
          (name "kernel.sched_min_granularity_ns")
          (comment "This parameter decides the minimum time a task will be be allowed to
run on CPU before being preempted out. We recommend setting it to
10ms.
")
          (value "10000000")
          
          (name "kernel.sched_wakeup_granularity_ns")
          (comment "Lowering this parameter improves wake-up latency and throughput for
latency critical tasks, particularly when a short duty cycle load
component must compete with CPU bound components.
")
          (value "15000000")))))
  (minio__sysfs__dependent_attributes (list
      
      (role "minio")
      (config (list
          
          (name "transparent_hugepages")
          (state "present")))))
  (minio__ferm__dependent_rules (jinja "{{ minio__env_ferm_dependent_rules }}"))
  (minio__nginx__dependent_upstreams (jinja "{{ minio__env_nginx_dependent_upstreams }}"))
  (minio__nginx__dependent_servers (jinja "{{ minio__env_nginx_dependent_servers }}")))
