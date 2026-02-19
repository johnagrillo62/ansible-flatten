(playbook "kubespray/roles/kubernetes/client/tasks/main.yml"
  (tasks
    (task "Set external kube-apiserver endpoint"
      (set_fact 
        (external_apiserver_address (jinja "{%- if loadbalancer_apiserver is defined and loadbalancer_apiserver.address is defined -%}") " " (jinja "{{ loadbalancer_apiserver.address }}") " " (jinja "{%- elif kubeconfig_localhost_ansible_host is defined and kubeconfig_localhost_ansible_host -%}") " " (jinja "{{ hostvars[groups['kube_control_plane'][0]].ansible_host }}") " " (jinja "{%- else -%}") " " (jinja "{{ kube_apiserver_access_address }}") " " (jinja "{%- endif -%}"))
        (external_apiserver_port (jinja "{%- if loadbalancer_apiserver is defined and loadbalancer_apiserver.address is defined and loadbalancer_apiserver.port is defined -%}") " " (jinja "{{ loadbalancer_apiserver.port | default(kube_apiserver_port) }}") " " (jinja "{%- else -%}") " " (jinja "{{ kube_apiserver_port }}") " " (jinja "{%- endif -%}")))
      (tags (list
          "facts")))
    (task "Create kube config dir for current/ansible become user"
      (file 
        (path (jinja "{{ ansible_env.HOME | default('/root') }}") "/.kube")
        (mode "0700")
        (state "directory")))
    (task "Write admin kubeconfig to current/ansible become user home"
      (copy 
        (src (jinja "{{ kube_config_dir }}") "/admin.conf")
        (dest (jinja "{{ ansible_env.HOME | default('/root') }}") "/.kube/config")
        (remote_src "true")
        (mode "0600")
        (backup "true")))
    (task "Create kube artifacts dir"
      (file 
        (path (jinja "{{ artifacts_dir }}"))
        (mode "0750")
        (state "directory"))
      (connection "local")
      (delegate_to "localhost")
      (become "false")
      (run_once "true")
      (when "kubeconfig_localhost"))
    (task "Wait for k8s apiserver"
      (wait_for 
        (host (jinja "{{ kube_apiserver_access_address }}"))
        (port (jinja "{{ kube_apiserver_port }}"))
        (timeout "180")))
    (task "Create kubeconfig localhost artifacts"
      (block (list
          
          (name "Generate admin kubeconfig using kubeadm")
          (command (jinja "{{ bin_dir }}") "/kubeadm kubeconfig user --client-name=kubernetes-admin-" (jinja "{{ cluster_name }}") " --org=kubeadm:cluster-admins --config " (jinja "{{ kube_config_dir }}") "/kubeadm-config.yaml")
          (register "kubeadm_admin_kubeconfig")
          (changed_when "false")
          (run_once "true")
          (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
          
          (name "Write admin kubeconfig on ansible host")
          (copy 
            (content (jinja "{{ kubeadm_admin_kubeconfig.stdout | from_yaml | combine(override, recursive=true) | to_nice_yaml(indent=2) }}"))
            (dest (jinja "{{ artifacts_dir }}") "/admin.conf")
            (mode "0600"))
          (vars 
            (admin_kubeconfig (jinja "{{ kubeadm_admin_kubeconfig.stdout | from_yaml }}"))
            (context "kubernetes-admin-" (jinja "{{ cluster_name }}") "@" (jinja "{{ cluster_name }}"))
            (override 
              (clusters (list
                  (jinja "{{ admin_kubeconfig['clusters'][0] | combine({'name': cluster_name, 'cluster': admin_kubeconfig['clusters'][0]['cluster'] | combine({'server': 'https://' + (external_apiserver_address | ansible.utils.ipwrap) + ':' + (external_apiserver_port | string)})}, recursive=true) }}")))
              (contexts (list
                  (jinja "{{ admin_kubeconfig['contexts'][0] | combine({'name': context, 'context': admin_kubeconfig['contexts'][0]['context'] | combine({'cluster': cluster_name})}, recursive=true) }}")))
              (current-context (jinja "{{ context }}"))))
          (delegate_to "localhost")
          (connection "local")
          (become "false")
          (run_once "true")))
      (when "kubeconfig_localhost"))
    (task "Copy kubectl binary to ansible host"
      (fetch 
        (src (jinja "{{ bin_dir }}") "/kubectl")
        (dest (jinja "{{ artifacts_dir }}") "/kubectl")
        (flat "true")
        (validate_checksum "false"))
      (register "copy_binary_result")
      (until "copy_binary_result is not failed")
      (retries "20")
      (become "false")
      (run_once "true")
      (when "kubectl_localhost"))
    (task "Create helper script kubectl.sh on ansible host"
      (copy 
        (content "#!/bin/bash
${BASH_SOURCE%/*}/kubectl --kubeconfig=${BASH_SOURCE%/*}/admin.conf \"$@\"
")
        (dest (jinja "{{ artifacts_dir }}") "/kubectl.sh")
        (mode "0755"))
      (connection "local")
      (become "false")
      (run_once "true")
      (delegate_to "localhost")
      (when "kubectl_localhost and kubeconfig_localhost"))))
