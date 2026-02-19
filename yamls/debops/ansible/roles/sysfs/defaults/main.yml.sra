(playbook "debops/ansible/roles/sysfs/defaults/main.yml"
  (sysfs__enabled (jinja "{{ False
                    if (ansible_virtualization_type in [\"lxc\", \"openvz\"] and
                        ansible_virtualization_role == \"guest\")
                    else True }}"))
  (sysfs__base_packages (list
      "sysfsutils"))
  (sysfs__packages (list))
  (sysfs__default_attributes (list
      
      (name "ksm")
      (comment "Kernel Same-page Merging (KSM) configuration.
These parameters can be useful on hosts that are used as Virtual Machine
hypervisors, to allow for lower memory footprint of virtual machines,
however this feature has certain security risks.
https://www.linux-kvm.org/page/KSM
https://en.wikipedia.org/wiki/Kernel_same-page_merging
")
      (state "defined")
      (options (list
          
          (name "kernel/mm/ksm/run")
          (comment "Enable Kernel Same-page Merging")
          (value "1")
          
          (name "kernel/mm/ksm/sleep_milisecs")
          (comment "How long to sleep between scans, in miliseconds")
          (value "20")
          
          (name "kernel/mm/ksm/pages_to_scan")
          (comment "How many pages to scan in one run")
          (value "100")))
      
      (name "transparent_hugepages")
      (comment "Configuration of Transparent HugePages support.
Disable THP by default to increase performance in certain applications
like MongoDB, Redis, MariaDB, PostgreSQL. This is only effective when
real HugePages support is configured.
https://www.kernel.org/doc/Documentation/vm/transhuge.txt
https://stackoverflow.com/a/42592382/6996970
")
      (state "defined")
      (options (list
          
          (name "kernel/mm/transparent_hugepage/enabled")
          (value "never")
          
          (name "kernel/mm/transparent_hugepage/defrag")
          (value "never")
          
          (name "kernel/mm/transparent_hugepage/khugepaged/defrag")
          (value "0")))))
  (sysfs__attributes (list))
  (sysfs__group_attributes (list))
  (sysfs__host_attributes (list))
  (sysfs__dependent_attributes (list))
  (sysfs__dependent_attributes_filter (jinja "{{ lookup(\"template\",
                                               \"lookup/sysfs__dependent_attributes_filter.j2\")
                                               | from_yaml }}"))
  (sysfs__combined_attributes (jinja "{{ sysfs__default_attributes
                                + sysfs__dependent_attributes_filter
                                + sysfs__attributes
                                + sysfs__group_attributes
                                + sysfs__host_attributes }}")))
