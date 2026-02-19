(playbook "debops/ansible/roles/hwraid/defaults/main.yml"
  (hwraid_distribution (jinja "{{ ansible_distribution }}"))
  (hwraid_release (jinja "{{ ansible_distribution_release }}"))
  (hwraid_blacklist (list))
  (hwraid_repository_apt_key_id "0073 C119 19A6 4146 4163  F711 6005 210E 23B3 D3B4")
  (hwraid_distribution_releases 
    (Debian (list
        "stretch"
        "squeeze"
        "sid"))
    (Ubuntu (list
        "wily"
        "vivid"
        "trusty")))
  (hwraid_device_database (list
      
      (module "3w_xxxx")
      (packages (list
          "tw_cli"
          "3ware-status"))
      (daemons (list
          "3ware-statusd"))
      
      (module "3w_9xxx")
      (packages (list
          "tw_cli"
          "3ware-status"))
      (daemons (list
          "3ware-statusd"))
      
      (module "mptsas")
      (packages (list
          "mpt-status"))
      (daemons (list
          "mpt-statusd"))
      
      (module "mpt2sas")
      (packages (list
          "sas2ircu"
          "sas2ircu-status"))
      (daemons (list
          "sas2ircu-statusd"))
      
      (module "megaraid_mm")
      (packages (list
          "megactl"
          "megaraid-status"))
      (daemons (list
          "megaraid-statusd"))
      
      (module "megaraid_mbox")
      (packages (list
          "megactl"
          "megaraid-status"))
      (daemons (list
          "megaraid-statusd"))
      
      (module "megaraid_sas")
      (packages (list
          "megactl"
          "megaraid-status"))
      (daemons (list
          "megaraidsas-statusd"))
      
      (module "aacraid")
      (packages (list
          "arcconf"
          "aacraid-status"))
      (daemons (list
          "aacraid-statusd"))
      
      (module "cciss")
      (packages (list
          "cciss-vol-status"))
      (daemons (list
          "cciss-vol-statusd"))))
  (hwraid__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ hwraid_repository_apt_key_id }}")))))
