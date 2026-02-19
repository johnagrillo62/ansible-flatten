(playbook "kubespray/roles/kubernetes-apps/external_cloud_controller/vsphere/defaults/main.yml"
  (external_vsphere_vcenter_port "443")
  (external_vsphere_insecure "true")
  (external_vsphere_cloud_controller_extra_args )
  (external_vsphere_cloud_controller_image_tag "v1.31.0")
  (external_vsphere_user (jinja "{{ lookup('env', 'VSPHERE_USER') }}"))
  (external_vsphere_password (jinja "{{ lookup('env', 'VSPHERE_PASSWORD') }}")))
