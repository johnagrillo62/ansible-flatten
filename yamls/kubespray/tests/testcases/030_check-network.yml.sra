(playbook "kubespray/tests/testcases/030_check-network.yml"
  (tasks
    (task "Check kubelet serving certificates approved with kubelet_csr_approver"
      (block (list
          
          (name "Get certificate signing requests")
          (command (jinja "{{ bin_dir }}") "/kubectl get csr -o jsonpath-as-json={.items[*]}")
          (register "csr_json")
          (changed_when "false")
          
          (name "Check there are csrs")
          (assert 
            (that "csrs | length > 0")
            (fail_msg "kubelet_rotate_server_certificates is " (jinja "{{ kubelet_rotate_server_certificates }}") " but no csr's found"))
          
          (name "Check there are Denied/Pending csrs")
          (assert 
            (that (list
                "csrs | rejectattr('status') | length == 0"
                "csrs | map(attribute='status.conditions') | flatten | selectattr('type', 'equalto', 'Denied') | length == 0"))
            (fail_msg "kubelet_csr_approver is enabled but CSRs are not approved"))))
      (when (list
          "kubelet_rotate_server_certificates | default(false)"
          "kubelet_csr_approver_enabled | default(kubelet_rotate_server_certificates | default(false))"))
      (vars 
        (csrs (jinja "{{ csr_json.stdout | from_json }}"))))
    (task "Approve kubelet serving certificates"
      (block (list
          
          (name "Get certificate signing requests")
          (command (jinja "{{ bin_dir }}") "/kubectl get csr -o name")
          (register "get_csr")
          (changed_when "false")
          
          (name "Check there are csrs")
          (assert 
            (that "get_csr.stdout_lines | length > 0")
            (fail_msg "kubelet_rotate_server_certificates is " (jinja "{{ kubelet_rotate_server_certificates }}") " but no csr's found"))
          
          (name "Approve certificates")
          (command (jinja "{{ bin_dir }}") "/kubectl certificate approve " (jinja "{{ get_csr.stdout_lines | join(' ') }}"))
          (register "certificate_approve")
          (when "get_csr.stdout_lines | length > 0")
          (changed_when "certificate_approve.stdout")))
      (when (list
          "kubelet_rotate_server_certificates | default(false)"
          "not (kubelet_csr_approver_enabled | default(kubelet_rotate_server_certificates | default(false)))")))
    (task "Create test namespace"
      (command (jinja "{{ bin_dir }}") "/kubectl create namespace test")
      (changed_when "false"))
    (task "Run 2 agnhost pods in test ns"
      (command 
        (cmd (jinja "{{ bin_dir }}") "/kubectl apply --namespace test -f -")
        (stdin "apiVersion: apps/v1
kind: Deployment
metadata:
  name: agnhost
spec:
  replicas: 2
  selector:
    matchLabels:
      app: agnhost
  template:
    metadata:
      labels:
        app: agnhost
    spec:
      containers:
      - name: agnhost
        image: " (jinja "{{ test_image_repo }}") ":" (jinja "{{ test_image_tag }}") "
        command: ['/agnhost', 'netexec', '--http-port=8080']
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop: ['ALL']
          runAsUser: 1000
          runAsNonRoot: true
          seccompProfile:
            type: RuntimeDefault
"))
      (changed_when "false"))
    (task "Check that all pods are running and ready"
      (block (list
          
          (name "Check Deployment is ready")
          (command (jinja "{{ bin_dir }}") "/kubectl rollout status deploy --namespace test agnhost --timeout=180s")
          (changed_when "false")
          
          (name "Get pod names")
          (command (jinja "{{ bin_dir }}") "/kubectl get pods -n test -o json")
          (changed_when "false")
          (register "pods_json")
          
          (name "Check pods IP are in correct network")
          (assert 
            (that "pods | selectattr('status.phase', '==', 'Running') | selectattr('status.podIP', 'ansible.utils.in_network', kube_pods_subnet) | length == 2"))
          
          (name "Curl between pods is working")
          (command (jinja "{{ bin_dir }}") "/kubectl -n test exec " (jinja "{{ item[0].metadata.name }}") " -- curl " (jinja "{{ item[1].status.podIP | ansible.utils.ipwrap}}") ":8080")
          (with_nested (list
              (jinja "{{ pods }}")
              (jinja "{{ pods }}")))
          (loop_control 
            (label (jinja "{{ item[0].metadata.name + ' --> ' + item[1].metadata.name }}")))))
      (rescue (list
          
          (name "List pods cluster-wide")
          (command (jinja "{{ bin_dir }}") "/kubectl get pods --all-namespaces -owide")
          (changed_when "false")
          
          (import_role 
            (name "cluster-dump"))
          
          (fail null)))
      (vars 
        (pods (jinja "{{ (pods_json.stdout | from_json)['items'] }}"))))))
