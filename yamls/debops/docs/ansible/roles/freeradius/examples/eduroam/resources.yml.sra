(playbook "debops/docs/ansible/roles/freeradius/examples/eduroam/resources.yml"
  (radius_pki_realm "domain")
  (radius_cert_file "/etc/pki/realms/" (jinja "{{ radius_pki_realm }}") "/default.crt")
  (radius_key_file "/etc/pki/realms/" (jinja "{{ radius_pki_realm }}") "/default.key")
  (radius_ca_file "/etc/pki/realms/" (jinja "{{ radius_pki_realm }}") "/CA.crt")
  (config_dir "/srv/eapol-test")
  (radius_access_point_password (jinja "{{ lookup(\"password\", secret
                                  + \"/radius/known-secret-password\") }}"))
  (radius_test_user_identity "a_user@" (jinja "{{ ansible_domain }}"))
  (radius_test_user_password (jinja "{{ lookup(\"password\", secret
                               + \"/radius/default-test-password\") }}"))
  (resources__host_files (list
      
      (content "#!/bin/bash

# Install eapol_test for testing RADIUS EAP connections

sudo apt-get update
sudo apt-get -yq install git build-essential \\
                         libssl-dev devscripts \\
                         pkg-config libnl-3-dev \\
                         libnl-genl-3-dev

git clone --depth 1 --no-single-branch https://github.com/FreeRADIUS/freeradius-server.git

cd freeradius-server/scripts/ci/

./eapol_test-build.sh

sudo cp ./eapol_test/eapol_test /usr/local/bin/
")
      (dest "/usr/local/bin/install-eapol_test")
      (mode "0755")
      
      (content "#
#   eapol_test -c eap-tls.conf -s \"" (jinja "{{ radius_access_point_password }}") "\" \\
#              -a <radius-ip-server>
#
network={
    key_mgmt=WPA-EAP
    eap=TTLS
    identity=\"" (jinja "{{ radius_test_user_identity }}") "\"
    anonymous_identity=\"anonymous@" (jinja "{{ ansible_domain }}") "\"

    # Uncomment to validate the server's certificate by checking
    # it was signed by this CA.
    ca_cert=\"" (jinja "{{ radius_ca_file }}") "\"
    password=\"" (jinja "{{ radius_test_user_password }}") "\"
    phase2=\"auth=PAP\"
}
")
      (dest (jinja "{{ config_dir }}") "/eap-tls.conf")
      (mode "0644")
      
      (content "#
#   eapol_test -c peap-mschapv2.conf -s \"" (jinja "{{ radius_access_point_password }}") "\" \\
#              -a <radius-ip-address>
#
network={
    key_mgmt=WPA-EAP
    eap=PEAP
    identity=\"" (jinja "{{ radius_test_user_identity }}") "\"
    anonymous_identity=\"anonymous@" (jinja "{{ ansible_domain }}") "\"

    # Uncomment to validate the server's certificate by checking
    # it was signed by this CA.
    ca_cert=\"" (jinja "{{ radius_ca_file }}") "\"
    password=\"" (jinja "{{ radius_test_user_password }}") "\"
    phase2=\"auth=MSCHAPV2 mschapv2_retry=0\"
    phase1=\"peapver=0\"
}
")
      (dest (jinja "{{ config_dir }}") "/peap-mschapv2.conf")
      (mode "0644")
      
      (content "#
#   eapol_test -c tls.conf -s \"" (jinja "{{ radius_access_point_password }}") "\" \\
#              -a <radius-ip-address>
#
network={
    key_mgmt=WPA-EAP
    eap=TLS
    anonymous_identity=\"anonymous@" (jinja "{{ ansible_domain }}") "\"

    # Uncomment to validate the server's certificate by checking
    # it was signed by this CA.
    ca_cert=\"" (jinja "{{ radius_ca_file }}") "\"

    # supplicant's public cert
    client_cert=\"" (jinja "{{ radius_cert_file }}") "\"

    # supplicant's private key
    private_key=\"" (jinja "{{ radius_key_file }}") "\"

    # password to decrypt private key
    private_key_passwd=\"\"
}
")
      (dest (jinja "{{ config_dir }}") "/tls.conf")
      (mode "0644"))))
