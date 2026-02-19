(playbook "sensu-ansible/tasks/ssl_generate.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml")))
    (task "Ensure OpenSSL is installed"
      (package 
        (name "openssl")
        (state "present")))
    (task "Ensure SSL generation directory exists"
      (file 
        (dest (jinja "{{ sensu_config_path }}") "/" (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}")))
      (when "sensu_master")
      (loop (list
          "ssl_generation"
          "ssl_generation/sensu_ssl_tool"
          "ssl_generation/sensu_ssl_tool/client"
          "ssl_generation/sensu_ssl_tool/server"
          "ssl_generation/sensu_ssl_tool/sensu_ca"
          "ssl_generation/sensu_ssl_tool/sensu_ca/private"
          "ssl_generation/sensu_ssl_tool/sensu_ca/certs")))
    (task "Ensure OpenSSL configuration is in place"
      (template 
        (src "openssl.cnf.j2")
        (dest (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/sensu_ca/openssl.cnf")
        (owner (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}")))
      (when "sensu_master"))
    (task
      (block (list
          
          (name "Ensure the Sensu CA serial configuration")
          (shell "echo 01 > sensu_ca/serial")
          (args 
            (chdir (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/")
            (creates (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/sensu_ca/serial"))
          (register "sensu_ca_new_serial")
          
          (name "Ensure sensu_ca/index.txt exists")
          (file 
            (dest (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/sensu_ca/index.txt")
            (state "touch"))
          (when "sensu_ca_new_serial is changed")
          
          (name "Generate Sensu CA certificate")
          (command "openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 1825 -out cacert.pem -outform PEM -subj /CN=SensuCA/ -nodes")
          (args 
            (chdir (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/sensu_ca")
            (creates (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/sensu_ca/cacert.pem"))
          
          (name "Generate CA cert")
          (command "openssl x509 -in cacert.pem -out cacert.cer -outform DER")
          (args 
            (chdir (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/sensu_ca")
            (creates (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/sensu_ca/cacert.cer"))
          
          (name "Generate server keys")
          (command "openssl genrsa -out key.pem 2048")
          (args 
            (chdir (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/server")
            (creates (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/server/key.pem"))
          
          (name "Generate server certificate signing request")
          (command "openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=sensu/O=server/ -nodes")
          (args 
            (chdir (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/server")
            (creates (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/server/req.pem"))
          
          (name "Sign the server certificate")
          (command "openssl ca -config openssl.cnf -in ../server/req.pem -out ../server/cert.pem -notext -batch -extensions server_ca_extensions")
          (args 
            (chdir (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/sensu_ca")
            (creates (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/server/cert.pem"))
          
          (name "Convert server certificate and key to PKCS12 formart")
          (command "openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:secret")
          (args 
            (chdir (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/server")
            (creates (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/server/keycert.p12"))
          
          (name "Generate client key")
          (command "openssl genrsa -out key.pem 2048")
          (args 
            (chdir (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/client")
            (creates (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/client/key.pem"))
          
          (name "Generate client certificate signing request")
          (command "openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=sensu/O=client/ -nodes")
          (args 
            (chdir (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/client")
            (creates (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/client/req.pem"))
          
          (name "Sign the client certificate")
          (command "openssl ca -config openssl.cnf -in ../client/req.pem -out ../client/cert.pem -notext -batch -extensions client_ca_extensions")
          (args 
            (chdir (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/sensu_ca")
            (creates (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/client/cert.pem"))
          
          (name "Convert client key/certificate to PKCS12 format")
          (command "openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:secret")
          (args 
            (chdir (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/client")
            (creates (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/client/keycert.p12"))))
      (when "sensu_master|bool")
      (become "true")
      (become_user (jinja "{{ sensu_user_name }}")))
    (task "Stash the Sensu SSL certs/keys"
      (fetch 
        (src (jinja "{{ sensu_config_path }}") "/ssl_generation/sensu_ssl_tool/" (jinja "{{ item }}"))
        (dest (jinja "{{ dynamic_data_store }}")))
      (when "sensu_master")
      (loop (list
          "sensu_ca/cacert.pem"
          "server/cert.pem"
          "server/key.pem"
          "client/cert.pem"
          "client/key.pem")))))
