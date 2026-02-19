(playbook "debops/ansible/roles/pki/tasks/ca_certificates.yml"
  (tasks
    (task "Set default trust policy for new certificates"
      (ansible.builtin.debconf 
        (name "ca-certificates")
        (question "ca-certificates/trust_new_crts")
        (vtype "select")
        (value (jinja "{{ \"yes\" if (pki_system_ca_certificates_trust_new | bool) else \"no\" }}"))))
    (task "Get list of known certificates"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && grep -E -e '^[^#].*$' /etc/ca-certificates.conf | sed -e 's/^!//' || true")
      (args 
        (executable "bash"))
      (register "pki_register_ca_certificates_known")
      (changed_when "False")
      (check_mode "False"))
    (task "Get list of untrusted certificates"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && grep -E -e '^!+' /etc/ca-certificates.conf | sed -e 's/^!//' || true")
      (args 
        (executable "bash"))
      (register "pki_register_ca_certificates_untrusted")
      (changed_when "False")
      (check_mode "False"))
    (task "Get list of trusted certificates"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && grep -E -e '^[^#!].*$' /etc/ca-certificates.conf | sed -e 's/^!//' || true")
      (args 
        (executable "bash"))
      (register "pki_register_ca_certificates_trusted")
      (changed_when "False")
      (check_mode "False"))
    (task "Get list of blacklisted certificates"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && grep -E -e '" (jinja "{{ pki_system_ca_certificates_blacklist | join(\"' -e '\") }}") "' /etc/ca-certificates.conf | sed -e 's/^!//' || true")
      (args 
        (executable "bash"))
      (register "pki_register_ca_certificates_blacklist")
      (changed_when "False")
      (check_mode "False")
      (when "pki_system_ca_certificates_blacklist is defined and pki_system_ca_certificates_blacklist"))
    (task "Get list of whitelisted certificates"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && grep -E -e '" (jinja "{{ pki_system_ca_certificates_whitelist | join(\"' -e '\") }}") "' /etc/ca-certificates.conf | sed -e 's/^!//' || true")
      (args 
        (executable "bash"))
      (register "pki_register_ca_certificates_whitelist")
      (changed_when "False")
      (check_mode "False")
      (when "pki_system_ca_certificates_whitelist is defined and pki_system_ca_certificates_whitelist"))
    (task "Configure system CA certificates"
      (ansible.builtin.template 
        (src "etc/ca-certificates.conf.j2")
        (dest "/etc/ca-certificates.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Reconfigure ca-certificates")))))
