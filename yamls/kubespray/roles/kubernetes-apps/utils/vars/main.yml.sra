(playbook "kubespray/roles/kubernetes-apps/utils/vars/main.yml"
  (_kubectl_apply_stdin (list
      (jinja "{{ kubectl }}")
      "apply"
      "-f"
      "-"
      "-n"
      (jinja "{{ k8s_namespace }}")
      "--server-side=\"" (jinja "{{ server_side_apply | lower }}") "\""))
  (server_side_apply "false")
  (kubectl_apply_stdin (jinja "{{ _kubectl_apply_stdin | join(' ') }}")))
