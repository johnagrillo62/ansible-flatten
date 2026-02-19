(playbook "tools/docker-credential-plugins-override.yml"
  (version "2")
  (services 
    (awx_1 
      (links (list
          "hashivault"
          "conjur")))
    (hashivault 
      (image "vault")
      (container_name "tools_hashivault_1")
      (ports (list
          "8200:8200"))
      (cap_add (list
          "IPC_LOCK"))
      (environment 
        (VAULT_DEV_ROOT_TOKEN_ID "vaultdev")))
    (conjur 
      (image "cyberark/conjur")
      (container_name "tools_conjur_1")
      (command "server -p 8300")
      (environment 
        (DATABASE_URL "postgres://awx@postgres/postgres")
        (CONJUR_DATA_KEY "dveUwOI/71x9BPJkIgvQRRBF3SdASc+HP4CUGL7TKvM="))
      (depends_on (list
          "postgres"))
      (links (list
          "postgres"))
      (ports (list
          "8300:8300")))))
