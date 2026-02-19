(playbook "debops/ansible/roles/sysctl/defaults/main.yml"
  (sysctl__enabled "True")
  (sysctl__writable (jinja "{{ ansible_local.sysctl.writable | d([]) }}"))
  (sysctl__shared_memory_base (jinja "{{ ((ansible_memtotal_mb | int * 1024 * 1024) - 8192) }}"))
  (sysctl__shared_memory_shmall_limiter (jinja "{{ 0.8
                                          if (ansible_memtotal_mb | int >= 4096)
                                          else 0.5 }}"))
  (sysctl__shared_memory_shmall (jinja "{{ ((sysctl__shared_memory_base | int *
                                    sysctl__shared_memory_shmall_limiter | float) / 4096)
                                  | round | int }}"))
  (sysctl__shared_memory_max_limiter (jinja "{{ 0.5
                                       if (ansible_memtotal_mb | int >= 4096)
                                       else 0.2 }}"))
  (sysctl__shared_memory_shmmax (jinja "{{ (sysctl__shared_memory_base | int *
                                   sysctl__shared_memory_max_limiter | float)
                                   | round | int }}"))
  (sysctl__hardening_enabled "True")
  (sysctl__system_ip_forwarding_enabled (jinja "{{ True
                                          if ansible_local.docker_server.installed | d(False)
                                          else False }}"))
  (sysctl__hardening_ipv6_disabled "False")
  (sysctl__hardening_experimental_enabled "False")
  (sysctl__tcp_performance_enabled "False")
  (sysctl__default_parameters (list
      
      (name "memory")
      (weight "10")
      (options (list
          
          (name "kernel.shmmax")
          (value (jinja "{{ sysctl__shared_memory_shmmax }}"))
          
          (name "kernel.shmall")
          (value (jinja "{{ sysctl__shared_memory_shmall }}"))
          
          (name "vm.swappiness")
          (comment "How aggressively the kernel swaps out anonymous memory relative to
pagecache and other caches. Increasing the value increases the amount
of swapping. Can be set to values between 0 and 100 inclusive.
")
          (value "60")
          
          (name "vm.vfs_cache_pressure")
          (comment "Tendency of the kernel to reclaim the memory which is used for caching of VFS
caches, versus pagecache and swap. Increasing this value increases the rate
at which VFS caches are reclaimed.
")
          (value "100")))
      
      (name "network")
      (weight "20")
      (options (list
          
          (name "net.ipv4.ip_forward")
          (value (jinja "{{ sysctl__system_ip_forwarding_enabled | bool | ternary(1, 0) }}"))
          (comment "Enable or disable IPv4 traffic forwarding")
          (state "present")
          
          (name "net.ipv6.conf.all.forwarding")
          (value (jinja "{{ sysctl__system_ip_forwarding_enabled | bool | ternary(1, 0) }}"))
          (comment "Enable or disable IPv6 traffic forwarding")
          (state "present")
          
          (name "net.ipv6.conf.all.accept_ra")
          (value "0")
          (comment "Ignore IPv6 RAs.")
          (state (jinja "{{ sysctl__hardening_enabled | bool | ternary(\"present\", \"absent\") }}"))
          
          (name "net.ipv6.conf.default.accept_ra")
          (value "0")
          (comment "Ignore IPv6 RAs.")
          (state (jinja "{{ sysctl__hardening_enabled | bool | ternary(\"present\", \"absent\") }}"))
          
          (name "net.ipv4.conf.all.rp_filter")
          (value "1")
          (comment "Enable RFC-recommended source validation feature.")
          (state (jinja "{{ sysctl__hardening_enabled | bool | ternary(\"present\", \"absent\") }}"))
          
          (name "net.ipv4.conf.default.rp_filter")
          (value "1")
          (comment "Enable RFC-recommended source validation feature.")
          (state (jinja "{{ sysctl__hardening_enabled | bool | ternary(\"present\", \"absent\") }}"))
          
          (name "net.ipv4.icmp_echo_ignore_broadcasts")
          (value "1")
          (comment "Reduce the surface on SMURF attacks.
Make sure to ignore ECHO broadcasts, which are only required in broad
network analysis.
")
          (state (jinja "{{ sysctl__hardening_enabled | bool | ternary(\"present\", \"absent\") }}"))
          
          (name "net.ipv4.icmp_ignore_bogus_error_responses")
          (value "1")
          (comment "Do not log bogus ICMP error responses.
Nobody would want to accept bogus error responses, so we can safely
ignore them.
")
          (state (jinja "{{ sysctl__hardening_enabled | bool | ternary(\"present\", \"absent\") }}"))
          
          (name "net.ipv4.icmp_ratelimit")
          (value "100")
          (comment "Limit the amount of traffic the system uses for ICMP.")
          (state (jinja "{{ sysctl__hardening_enabled | bool | ternary(\"present\", \"absent\") }}"))
          
          (name "net.ipv4.icmp_ratemask")
          (value "88089")
          (comment "Adjust the ICMP ratelimit to include ping, dst unreachable,
source quench, ime exceed, param problem, timestamp reply,
information reply
")
          (state (jinja "{{ sysctl__hardening_enabled | bool | ternary(\"present\", \"absent\") }}"))
          
          (name "net.ipv6.conf.all.disable_ipv6")
          (value "1")
          (comment "Disable IPv6.")
          (state (jinja "{{ sysctl__hardening_ipv6_disabled | bool | ternary(\"present\", \"absent\") }}"))
          
          (name "net.ipv4.tcp_timestamps")
          (value "0")
          (comment "Protect against wrapping sequence numbers at gigabit speeds.")
          (state (jinja "{{ (sysctl__hardening_enabled | bool and
                    not (ansible_virtualization_role == \"guest\" and ansible_virtualization_type == \"openvz\"))
                  | ternary(\"present\", \"absent\") }}"))
          
          (name "net.ipv4.conf.all.arp_ignore")
          (value "1")
          (comment "Define restriction level for announcing the local source IP.")
          (state (jinja "{{ sysctl__hardening_experimental_enabled | bool | ternary(\"present\", \"absent\") }}"))
          
          (name "net.ipv4.conf.all.arp_announce")
          (value "2")
          (comment "Define mode for sending replies in response to received ARP requests
that resolve local target IP addresses
")
          (state (jinja "{{ sysctl__hardening_experimental_enabled | bool | ternary(\"present\", \"absent\") }}"))
          
          (name "net.ipv4.tcp_rfc1337")
          (value "1")
          (comment "RFC 1337 fix F1.")
          (state (jinja "{{ (sysctl__hardening_enabled | bool and
                    not (ansible_virtualization_role == \"guest\" and
                         ansible_virtualization_type == \"openvz\"))
                  | ternary(\"present\", \"absent\") }}"))
          
          (name "net.ipv4.tcp_slow_start_after_idle")
          (value (jinja "{{ sysctl__tcp_performance_enabled | bool | ternary(0, 1) }}"))
          (comment "If set, provide RFC2861 behavior and time out the congestion window
after an idle period. An idle period is defined at the current RTO.
If unset, the congestion window will not be timed out after an idle
period.
")
          (state "present")))
      
      (name "protect-links")
      (filename (jinja "{{ \"protect-links.conf\"
                  if (ansible_distribution_release in [\"stretch\", \"buster\", \"bullseye\"])
                  else \"99-protect-links.conf\" }}"))
      (divert "True")
      (comment "Protected links

Protects against creating or following links under certain conditions
Debian kernels have both set to 1 (restricted)
See https://www.kernel.org/doc/Documentation/sysctl/fs.txt
")
      (options (list
          
          (name "fs.protected_fifos")
          (value "1")
          
          (name "fs.protected_hardlinks")
          (value "1")
          
          (name "fs.protected_regular")
          (value "2")
          
          (name "fs.protected_symlinks")
          (value "1")))
      
      (name "pid-max")
      (filename "50-pid-max.conf")
      (comment "This file is part of systemd.

systemd is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

See sysctl.d(5) and core(5) for documentation.

To override settings in this file, create a local file in /etc
(e.g. /etc/sysctl.d/90-override.conf), and put any assignments
there.
")
      (state (jinja "{{ \"present\"
               if ((ansible_local.core.is_64bits | d(True)) | bool)
               else \"absent\" }}"))
      (options (list
          
          (name "kernel.pid_max")
          (comment "Bump the numeric PID range to its maximum of 2^22 (from the in-kernel default
of 2^16), to make PID collisions less likely.
")
          (value "4194304")))))
  (sysctl__parameters (list))
  (sysctl__group_parameters (list))
  (sysctl__host_parameters (list))
  (sysctl__dependent_parameters (list))
  (sysctl__combined_parameters (jinja "{{ sysctl__default_parameters
                                 + lookup(\"flattened\", sysctl__dependent_parameters, wantlist=True)
                                 + sysctl__parameters
                                 + sysctl__group_parameters
                                 + sysctl__host_parameters }}")))
