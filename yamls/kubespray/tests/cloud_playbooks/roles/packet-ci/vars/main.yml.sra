(playbook "kubespray/tests/cloud_playbooks/roles/packet-ci/vars/main.yml"
  (scenarios 
    (separate (list
        
        (node_groups (list
            "kube_control_plane"))
        
        (node_groups (list
            "kube_node"))
        
        (node_groups (list
            "etcd"))))
    (ha (list
        
        (node_groups (list
            "kube_control_plane"
            "etcd"))
        
        (node_groups (list
            "kube_control_plane"
            "etcd"))
        
        (node_groups (list
            "kube_node"
            "etcd"))))
    (default (list
        
        (node_groups (list
            "kube_control_plane"
            "etcd"))
        
        (node_groups (list
            "kube_node"))))
    (all-in-one (list
        
        (node_groups (list
            "kube_control_plane"
            "etcd"
            "kube_node"))))
    (ha-recover (list
        
        (node_groups (list
            "kube_control_plane"
            "etcd"))
        
        (node_groups (list
            "kube_control_plane"
            "etcd"
            "broken_kube_control_plane"
            "broken_etcd"))
        
        (node_groups (list
            "kube_node"
            "etcd"))))
    (ha-recover-noquorum (list
        
        (node_groups (list
            "kube_control_plane"
            "etcd"
            "broken_kube_control_plane"
            "broken_etcd"))
        
        (node_groups (list
            "kube_control_plane"
            "etcd"
            "broken_kube_control_plane"
            "broken_etcd"))
        
        (node_groups (list
            "kube_node"
            "etcd"))))
    (node-etcd-client (list
        
        (node_groups (list
            "kube_node"
            "kube_control_plane"
            "etcd"))
        
        (node_groups (list
            "kube_node"
            "etcd"))
        
        (node_groups (list
            "kube_node"
            "etcd"))
        
        (node_groups (list
            "kube_node")))))
  (ci_job_id (jinja "{{ lookup('ansible.builtin.env', 'CI_JOB_ID', default=undefined) }}"))
  (pod_name (jinja "{{ lookup('ansible.builtin.env', 'POD_NAME', default=undefined) }}"))
  (pod_uid (jinja "{{ lookup('ansible.builtin.env', 'POD_UID', default=undefined) }}"))
  (pod_namespace (jinja "{{ lookup('ansible.builtin.env', 'POD_NAMESPACE', default=undefined) }}"))
  (cloudinit_config "#cloud-config
 users:
   - name: " (jinja "{{ lookup('env', 'ANSIBLE_REMOTE_USER') }}") "
     sudo: ALL=(ALL) NOPASSWD:ALL
     shell: /bin/bash
     lock_passwd: False
     ssh_authorized_keys:
       - " (jinja "{{ ssh_key.public_key }}") "
 fs_setup:
   - device: '/dev/disk/by-id/virtio-2825A83CBDC8A32D5E'
     filesystem: 'ext4'
     partition: 'none'
 mounts:
   - ['/dev/disk/by-id/virtio-2825A83CBDC8A32D5E', '/tmp/releases']
")
  (ignition_config 
    (ignition 
      (version "3.2.0"))
    (passwd 
      (users (list
          
          (name (jinja "{{ lookup('env', 'ANSIBLE_REMOTE_USER') }}"))
          (groups (list
              "sudo"
              "wheel"))
          (sshAuthorizedKeys (list
              (jinja "{{ ssh_key.public_key }}"))))))
    (storage 
      (filesystems (list
          
          (device "/dev/disk/by-id/virtio-2825A83CBDC8A32D5E")
          (format "ext4")
          (path "/tmp/releases")
          (wipeFilesystem "true"))))))
