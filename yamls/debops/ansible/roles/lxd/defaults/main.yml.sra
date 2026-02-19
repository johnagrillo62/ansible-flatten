(playbook "debops/ansible/roles/lxd/defaults/main.yml"
  (lxd__upstream_enabled "True")
  (lxd__upstream_type (jinja "{{ \"apt\"
                        if (ansible_distribution == \"Ubuntu\")
                        else \"git\" }}"))
  (lxd__upstream_gpg_key (list
      "602F 5676 63E5 93BC BD14  F338 C638 974D 6479 2D67"
      "5DE3 E050 9C47 EA3C F04A  42D3 4AEE 18F8 3AFD EB23"))
  (lxd__upstream_git_repository "https://github.com/lxc/lxd")
  (lxd__upstream_git_release "stable-4.0")
  (lxd__golang_gosrc (jinja "{{ ansible_local.golang.gosrc | d(\"\") }}"))
  (lxd__binary (jinja "{{ ansible_local.golang.binaries[\"lxd\"]
                 if (ansible_local.golang.binaries.lxd | d())
                 else \"/usr/bin/lxd\" }}"))
  (lxd__base_packages (list
      "dnsmasq-base"
      "lxcfs"
      "squashfs-tools"))
  (lxd__packages (list))
  (lxd__group "lxd")
  (lxd__admin_accounts (jinja "{{ ansible_local.core.admin_users | d([]) }}"))
  (lxd__default_preseed (list
      
      (name "server-default")
      (seed 
        (config ))
      
      (name "network-default")
      (seed 
        (networks (list
            
            (name "lxdbr0")
            (config 
              (ipv4.address "auto")
              (ipv6.address "auto"))
            (description "")
            (type ""))))
      
      (name "storage-default")
      (seed 
        (storage_pools (list
            
            (name "default")
            (config )
            (description "")
            (driver "dir"))))
      
      (name "profile-default")
      (seed 
        (profiles (list
            
            (name "default")
            (config )
            (description "")
            (devices 
              (eth0 
                (name "eth0")
                (nictype "bridged")
                (parent "lxdbr0")
                (type "nic"))
              (root 
                (path "/")
                (pool "default")
                (type "disk"))))))
      
      (name "cluster-default")
      (seed 
        (cluster null))))
  (lxd__preseed (list))
  (lxd__group_preseed (list))
  (lxd__host_preseed (list))
  (lxd__combined_preseed (jinja "{{ lxd__default_preseed
                           + lxd__preseed
                           + lxd__group_preseed
                           + lxd__host_preseed }}"))
  (lxd__init_preseed (jinja "{{ False
                       if (ansible_local | d() and ansible_local.lxd | d() and
                           (ansible_local.lxd.installed | d()) | bool)
                       else True }}"))
  (lxd__preseed_data (jinja "{{ lookup(\"template\", \"lookup/lxd__preseed_data.j2\") }}"))
  (lxd__golang__dependent_packages (list
      
      (name "lxd")
      (state (jinja "{{ \"present\" if lxd__upstream_enabled | bool else \"absent\" }}"))
      (upstream_type (jinja "{{ lxd__upstream_type }}"))
      (apt_packages (list
          "lxd"
          "lxd-client"))
      (apt_dev_packages (list
          "autoconf"
          "automake"
          "tcl"
          "libacl1-dev"
          "libcap-dev"
          "liblxc1"
          "lxc-dev"
          "libtool"
          "libuv1-dev"
          "make"
          "pkg-config"
          "libapparmor-dev"
          "libseccomp-dev"
          "libcap-dev"
          "libudev-dev"
          "libsqlite3-dev"
          "liblz4-dev"))
      (gpg (jinja "{{ lxd__upstream_gpg_key }}"))
      (git (list
          
          (repo (jinja "{{ lxd__upstream_git_repository }}"))
          (version (jinja "{{ lxd__upstream_git_release }}"))
          (depth "50")
          (build_script "export GOPATH=\"${HOME}/go\"
make deps
export CGO_CFLAGS=\"-I${HOME}/go/deps/sqlite/ -I${HOME}/go/deps/libco/ -I${HOME}/go/deps/raft/include/ -I${HOME}/go/deps/dqlite/include/\"
export CGO_LDFLAGS=\"-L${HOME}/go/deps/sqlite/.libs/ -L${HOME}/go/deps/libco/ -L${HOME}/go/deps/raft/.libs -L${HOME}/go/deps/dqlite/.libs/\"
export LD_LIBRARY_PATH=\"${HOME}/go/deps/sqlite/.libs/:${HOME}/go/deps/libco/:${HOME}/go/deps/raft/.libs/:${HOME}/go/deps/dqlite/.libs/\"
export CGO_LDFLAGS_ALLOW=\"(-Wl,-wrap,pthread_create)|(-Wl,-z,now)\"
make
")))
      (git_binaries (list
          
          (src (jinja "{{ lxd__upstream_git_repository.split(\"://\")[1] + \"/../../../../bin/lxd\" }}"))
          (dest "lxd")
          
          (src (jinja "{{ lxd__upstream_git_repository.split(\"://\")[1] + \"/../../../../bin/lxd-agent\" }}"))
          (dest "lxd-agent")
          
          (src (jinja "{{ lxd__upstream_git_repository.split(\"://\")[1] + \"/../../../../bin/lxd-benchmark\" }}"))
          (dest "lxd-benchmark")
          
          (src (jinja "{{ lxd__upstream_git_repository.split(\"://\")[1] + \"/../../../../bin/lxd-p2c\" }}"))
          (dest "lxd-p2c")
          
          (src (jinja "{{ lxd__upstream_git_repository.split(\"://\")[1] + \"/../../../../bin/lxc\" }}"))
          (dest "lxc")
          
          (src (jinja "{{ lxd__upstream_git_repository.split(\"://\")[1] + \"/../../../../bin/lxc-to-lxd\" }}"))
          (dest "lxc-to-lxd")
          
          (src (jinja "{{ lxd__upstream_git_repository.split(\"://\")[1] + \"/../../../../bin/fuidshift\" }}"))
          (dest "fuidshift")))))
  (lxd__logrotate__dependent_config (list
      
      (filename "lxd")
      (divert (jinja "{{ False if lxd__upstream_enabled | bool else True }}"))
      (log "/var/log/lxd/lxd.log")
      (options "copytruncate
daily
rotate 7
delaycompress
compress
notifempty
missingok
")
      (state "present")))
  (lxd__sysctl__dependent_parameters (list
      
      (name "lxd-inotify")
      (divert (jinja "{{ False if lxd__upstream_enabled | bool else True }}"))
      (weight "10")
      (options (list
          
          (name "fs.inotify.max_user_instances")
          (comment "Increase the user inotify instance limit to allow for about
100 containers to run before the limit is hit again
")
          (value "1024"))))))
