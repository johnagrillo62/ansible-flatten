(playbook "yaml/roles/vpn/tasks/openvpn.yml"
  (list
    
    (name "Install OpenVPN and dependencies")
    (apt "pkg=" (jinja "{{ item }}") " state=present")
    (with_items (list
        "dnsmasq"
        "openvpn"
        "udev"))
    (tags (list
        "dependencies"))
    
    (name "Generate RSA keys for the CA and Server")
    (command "openssl genrsa -out " (jinja "{{ item }}") ".key " (jinja "{{ openvpn_key_size }}") " chdir=" (jinja "{{ openvpn_path }}") " creates=" (jinja "{{ item }}") ".key")
    (with_items (list
        "ca"
        "server"))
    
    (name "Create directories for clients")
    (file "path=" (jinja "{{ openvpn_path }}") "/" (jinja "{{ item }}") " state=directory")
    (with_items (jinja "{{ openvpn_clients }}"))
    
    (name "Generate RSA keys for the clients")
    (command "openssl genrsa -out client.key " (jinja "{{ openvpn_key_size }}") " chdir=" (jinja "{{ openvpn_path }}") "/" (jinja "{{ item }}") " creates=client.key")
    (with_items (jinja "{{ openvpn_clients }}"))
    
    (name "Set the proper permissions on all RSA keys")
    (file "path=" (jinja "{{ openvpn_path }}") " recurse=yes state=directory owner=root group=root mode=0600")
    
    (name "Generate CA certificate")
    (command "openssl req -nodes -batch -new -x509 -key " (jinja "{{ openvpn_ca }}") ".key -out " (jinja "{{ openvpn_ca }}") ".crt -days " (jinja "{{ openvpn_days_valid }}") " -subj \"" (jinja "{{ openssl_request_subject }}") "/CN=sovereign-ca-certificate\" creates=" (jinja "{{ openvpn_ca }}") ".crt")
    
    (name "Generate the OpenSSL configuration that will be used for the Server certificate's req and ca commands")
    (template "src=openssl-server-certificate.cnf.j2 dest=" (jinja "{{ openvpn_path }}") "/openssl-server-certificate.cnf")
    
    (name "Seed a blank database file that will be used when generating the Server's certificate")
    (file "path=" (jinja "{{ openvpn_path }}") "/index.txt state=touch")
    
    (name "Seed a serial file that will be used when generating the Server's certificate")
    (copy "content=\"01\" dest=" (jinja "{{ openvpn_path }}") "/serial")
    
    (name "Generate CSR for the Server")
    (command "openssl req -batch -extensions server -new -key server.key -out server.csr -config " (jinja "{{ openvpn_path }}") "/openssl-server-certificate.cnf chdir=" (jinja "{{ openvpn_path }}") " creates=server.csr")
    
    (name "Generate certificate for the Server")
    (command "openssl ca -batch -extensions server -in server.csr -out server.crt -config openssl-server-certificate.cnf chdir=" (jinja "{{ openvpn_path }}") " creates=server.crt")
    
    (name "Generate CSRs for the clients")
    (command "openssl req -new -key client.key -out client.csr -subj \"" (jinja "{{ openssl_request_subject }}") "/CN=" (jinja "{{ item }}") "\" chdir=" (jinja "{{ openvpn_path }}") "/" (jinja "{{ item }}") " creates=client.csr")
    (with_items (jinja "{{ openvpn_clients }}"))
    
    (name "Generate certificates for the clients")
    (command "openssl x509 -CA " (jinja "{{ openvpn_ca }}") ".crt -CAkey " (jinja "{{ openvpn_ca }}") ".key -CAcreateserial -req -days " (jinja "{{ openvpn_days_valid }}") " -in client.csr -out client.crt chdir=" (jinja "{{ openvpn_path }}") "/" (jinja "{{ item }}") " creates=client.crt")
    (with_items (jinja "{{ openvpn_clients }}"))
    
    (name "Generate HMAC firewall key")
    (command "openvpn --genkey --secret " (jinja "{{ openvpn_hmac_firewall }}") " creates=" (jinja "{{ openvpn_hmac_firewall }}"))
    
    (name "Register CA certificate contents")
    (command "cat ca.crt chdir=" (jinja "{{ openvpn_path }}"))
    (register "openvpn_ca_contents")
    (tags (list
        "skip_ansible_lint"))
    
    (name "Register client certificate contents")
    (command "cat client.crt chdir=" (jinja "{{ openvpn_path }}") "/" (jinja "{{ item }}"))
    (with_items (jinja "{{ openvpn_clients }}"))
    (register "openvpn_client_certificates")
    (tags (list
        "skip_ansible_lint"))
    
    (name "Register client key contents")
    (command "cat client.key chdir=" (jinja "{{ openvpn_path }}") "/" (jinja "{{ item }}"))
    (with_items (jinja "{{ openvpn_clients }}"))
    (register "openvpn_client_keys")
    (tags (list
        "skip_ansible_lint"))
    
    (name "Register HMAC firewall contents")
    (command "cat ta.key chdir=" (jinja "{{ openvpn_path }}"))
    (register "openvpn_hmac_firewall_contents")
    (tags (list
        "skip_ansible_lint"))
    
    (name "Create the client configs")
    (template "src=client.cnf.j2 dest=" (jinja "{{ openvpn_path }}") "/" (jinja "{{ item[0] }}") "/" (jinja "{{ openvpn_server }}") ".ovpn")
    (with_together (list
        (jinja "{{ openvpn_clients }}")
        (jinja "{{ openvpn_client_certificates.results }}")
        (jinja "{{ openvpn_client_keys.results }}")))
    
    (name "Generate Diffie-Hellman parameters (this will take a while)")
    (command "openssl dhparam -out " (jinja "{{ openvpn_dhparam }}") " " (jinja "{{ openvpn_key_size }}") " creates=" (jinja "{{ openvpn_dhparam }}"))
    
    (name "Add empty rc.local if it doesn't exist")
    (copy "src=rc.local dest=/etc/rc.local mode=0700 owner=root group=root force=no")
    
    (name "custom rc.local file with iptables rules")
    (template "src=rc.local_ansible_openvpn dest=/etc/rc.local_ansible_openvpn mode=0700 owner=root group=root")
    
    (name "Ensure custom rc.local file is included in rc.local")
    (lineinfile "dest=/etc/rc.local line='bash /etc/rc.local_ansible_openvpn' insertbefore='exit 0'")
    
    (name "Run custom rc file")
    (command "bash /etc/rc.local_ansible_openvpn")
    (changed_when "False")
    
    (name "Enable IPv4 traffic forwarding")
    (sysctl "name=net.ipv4.ip_forward value=1")
    
    (name "Allow OpenVPN through ufw")
    (ufw "rule=allow port=" (jinja "{{ openvpn_port }}") " proto=" (jinja "{{ openvpn_protocol }}"))
    (tags "ufw")
    
    (name "Copy OpenVPN configuration file into place")
    (template "src=etc_openvpn_server.conf.j2 dest=/etc/openvpn/server.conf")
    (notify "restart openvpn")
    
    (name "Copy OpenVPN PAM configuration file into place")
    (copy "src=etc_pam.d_openvpn dest=/etc/pam.d/openvpn")
    (notify "restart openvpn")
    
    (name "Enable OpenVPN server systemd service unit")
    (service "name=openvpn@server enabled=yes")
    
    (meta "flush_handlers")
    
    (name "Copy dnsmasq configuration file into place")
    (copy "src=etc_dnsmasq.conf dest=/etc/dnsmasq.conf")
    (notify "restart dnsmasq")
    
    (name "Copy the ca.crt and ta.key files that clients will need in order to connect to the OpenVPN server")
    (command "cp " (jinja "{{ openvpn_path }}") "/" (jinja "{{ item[1] }}") " " (jinja "{{ openvpn_path }}") "/" (jinja "{{ item[0] }}"))
    (tags (list
        "skip_ansible_lint"))
    (with_nested (list
        (jinja "{{ openvpn_clients }}")
        (list
          "ca.crt"
          "ta.key")))
    
    (name "Retrieve the files that clients will need in order to connect to the OpenVPN server")
    (fetch "src=" (jinja "{{ openvpn_path }}") "/" (jinja "{{ item[0] }}") "/" (jinja "{{ item[1] }}") " dest=/tmp/sovereign-openvpn-files")
    (with_nested (list
        (jinja "{{ openvpn_clients }}")
        (list
          "client.crt"
          "client.key"
          "ca.crt"
          "ta.key"
          (jinja "{{ openvpn_server }}") ".ovpn")))
    
    (name "Pause for OpenVPN instructions...")
    (pause "seconds=5 prompt=\"You are ready to set up your OpenVPN clients. The files that you need are in /tmp/sovereign-openvpn-files. Make sure LZO compression is enabled and that you provide the ta.key file for the TLS-Auth option with a direction of '1'. Press any key to continue...\"")))
