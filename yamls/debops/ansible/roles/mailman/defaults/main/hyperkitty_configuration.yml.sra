(playbook "debops/ansible/roles/mailman/defaults/main/hyperkitty_configuration.yml"
  (mailman__hyperkitty_original_configuration (list
      
      (name "general")
      (options (list
          
          (name "base_url")
          (comment "This is your HyperKitty installation, preferably on the localhost. This
address will be used by Mailman to forward incoming emails to HyperKitty
for archiving. It does not need to be publicly available, in fact it's
better if it is not.
")
          (value "http://localhost/mailman3/hyperkitty/")
          
          (name "api_key")
          (comment "Shared API key, must be the identical to the value in HyperKitty's
settings.
")
          (value "SecretArchiverAPIKey")))))
  (mailman__hyperkitty_default_configuration (list
      
      (name "general")
      (options (list
          
          (name "base_url")
          (value (jinja "{{ \"https://\" + mailman__fqdn + \"/hyperkitty/\" }}"))
          
          (name "api_key")
          (value (jinja "{{ ansible_local.mailman.archiver_key | d(\"SecretArchiverAPIKey\") }}"))))))
  (mailman__hyperkitty_configuration (list))
  (mailman__hyperkitty_group_configuration (list))
  (mailman__hyperkitty_host_configuration (list))
  (mailman__hyperkitty_combined_configuration (jinja "{{ mailman__hyperkitty_original_configuration
                                                + mailman__hyperkitty_default_configuration
                                                + mailman__hyperkitty_configuration
                                                + mailman__hyperkitty_group_configuration
                                                + mailman__hyperkitty_host_configuration }}")))
