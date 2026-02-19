(playbook "debops/ansible/roles/ipxe/tasks/debian_netboot.yml"
  (tasks
    (task "Create Debian netboot directories"
      (ansible.builtin.file 
        (path (jinja "{{ ipxe__debian_netboot_src + \"/\" + item.release + \"/\" + item.architecture
              + \"/\" + item.netboot_version + (item.netboot_subdir | d(\"\")) }}"))
        (state "directory")
        (mode "0755"))
      (loop (jinja "{{ ipxe__debian_netboot_combined_release_map | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'ignore'] and item.release in ipxe__debian_netboot_releases and item.architecture in ipxe__debian_netboot_architectures"))
    (task "Create Debian installer directories"
      (ansible.builtin.file 
        (path (jinja "{{ ipxe__debian_netboot_pxe_root + \"/\" + item.release + \"/\" + item.architecture
              + \"/\" + item.netboot_version + (item.netboot_subdir | d(\"\")) }}"))
        (state "directory")
        (mode "0775"))
      (loop (jinja "{{ ipxe__debian_netboot_combined_release_map | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'ignore'] and item.release in ipxe__debian_netboot_releases and item.architecture in ipxe__debian_netboot_architectures"))
    (task "Download Debian netboot tarballs"
      (ansible.builtin.get_url 
        (url (jinja "{{ item.netboot_url | d(ipxe__debian_netboot_mirror + \"/dists/\" + item.release
                                  + \"/main/installer-\" + item.architecture + \"/\"
                                  + item.netboot_version + \"/images/netboot\"
                                  + (item.netboot_subdir | d(\"\")) + \"/netboot.tar.gz\") }}"))
        (dest (jinja "{{ ipxe__debian_netboot_src + \"/\" + item.release + \"/\" + item.architecture + \"/\"
              + item.netboot_version + (item.netboot_subdir | d(\"\")) + \"/netboot.tar.gz\" }}"))
        (checksum (jinja "{{ item.netboot_checksum | d(omit) }}"))
        (mode "0644"))
      (loop (jinja "{{ ipxe__debian_netboot_combined_release_map | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'ignore'] and item.release in ipxe__debian_netboot_releases and item.architecture in ipxe__debian_netboot_architectures")
      (register "ipxe__register_get_netboot")
      (until "ipxe__register_get_netboot is succeeded"))
    (task "Unpack Debian netboot tarballs"
      (ansible.builtin.unarchive 
        (src (jinja "{{ ipxe__debian_netboot_src + \"/\" + item.release + \"/\" + item.architecture + \"/\"
             + item.netboot_version + (item.netboot_subdir | d(\"\")) + \"/netboot.tar.gz\" }}"))
        (dest (jinja "{{ ipxe__debian_netboot_pxe_root + \"/\" + item.release + \"/\" + item.architecture + \"/\"
              + item.netboot_version + (item.netboot_subdir | d(\"\")) }}"))
        (mode "u=rwX,g=rwX,o=rX")
        (remote_src "True")
        (creates (jinja "{{ ipxe__debian_netboot_pxe_root + \"/\" + item.release + \"/\" + item.architecture + \"/\"
                 + item.netboot_version + (item.netboot_subdir | d(\"\")) + \"/pxelinux.0\" }}")))
      (loop (jinja "{{ ipxe__debian_netboot_combined_release_map | debops.debops.parse_kv_items }}"))
      (register "ipxe__register_debian_installer")
      (when "item.name | d() and item.state | d('present') not in ['absent', 'ignore'] and item.release in ipxe__debian_netboot_releases and item.architecture in ipxe__debian_netboot_architectures"))
    (task "Point current Debian netboot symlink to correct version"
      (ansible.builtin.file 
        (path (jinja "{{ ipxe__debian_netboot_pxe_root + \"/\" + item.release + \"/\" + item.architecture + \"/current\" }}"))
        (src (jinja "{{ item.netboot_version }}"))
        (state "link")
        (mode "0775"))
      (loop (jinja "{{ ipxe__debian_netboot_combined_release_map | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'ignore'] and item.release in ipxe__debian_netboot_releases and item.architecture in ipxe__debian_netboot_architectures and (item.netboot_current | d(True)) | bool"))
    (task "Create Debian firmware directories"
      (ansible.builtin.file 
        (path (jinja "{{ ipxe__debian_netboot_src + \"/\" + item.release + \"/non-free/\" + item.firmware_version }}"))
        (state "directory")
        (mode "0755"))
      (loop (jinja "{{ ipxe__debian_netboot_combined_release_map | debops.debops.parse_kv_items }}"))
      (when "ipxe__debian_netboot_firmware | bool and item.name | d() and item.state | d('present') not in ['absent', 'ignore'] and item.release in ipxe__debian_netboot_releases and item.firmware_version | d()"))
    (task "Download Debian firmware tarballs"
      (ansible.builtin.get_url 
        (url (jinja "{{ item.firmware_url | d(ipxe__debian_netboot_firmware_mirror + \"/\" + item.release + \"/\"
                                   + item.firmware_version + \"/firmware.cpio.gz\") }}"))
        (dest (jinja "{{ ipxe__debian_netboot_src + \"/\" + item.release + \"/non-free/\"
              + item.firmware_version + \"/firmware.cpio.gz\" }}"))
        (checksum (jinja "{{ item.firmware_checksum | d(omit) }}"))
        (mode "0644"))
      (loop (jinja "{{ ipxe__debian_netboot_combined_release_map | debops.debops.parse_kv_items }}"))
      (when "ipxe__debian_netboot_firmware | bool and item.name | d() and item.state | d('present') not in ['absent', 'ignore'] and item.release in ipxe__debian_netboot_releases and item.firmware_version | d()")
      (register "ipxe__register_get_firmware")
      (until "ipxe__register_get_firmware is succeeded"))
    (task "Include firmware in the Debian netboot installers"
      (ansible.builtin.shell "cat " (jinja "{{ ipxe__debian_netboot_src + \"/\" + item.item.release + \"/non-free/\"
                + item.item.firmware_version + \"/firmware.cpio.gz\" }}") " >> " (jinja "{{ ipxe__debian_netboot_pxe_root + \"/\" + item.item.release + \"/\" + item.item.architecture + \"/\"
                   + item.item.netboot_version + (item.item.netboot_subdir | d(\"\")) + \"/debian-installer/\"
                   + item.item.architecture + \"/initrd.gz\" }}"))
      (loop (jinja "{{ ipxe__register_debian_installer.results }}"))
      (register "ipxe__register_netboot_merge")
      (changed_when "ipxe__register_netboot_merge.changed | bool")
      (when "ipxe__debian_netboot_firmware | bool and item.item.firmware_version | d() and item is changed"))))
