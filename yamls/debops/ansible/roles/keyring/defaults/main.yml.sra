(playbook "debops/ansible/roles/keyring/defaults/main.yml"
  (keyring__enabled "True")
  (keyring__local_path "")
  (keyring__keybase_api "https://keybase.io/")
  (keyring__keyserver "hkp://keyserver.ubuntu.com")
  (keyring__gpg_version (jinja "{{ ansible_local.keyring.gpg_version | d(\"0.0.0\") }}"))
  (keyring__base_packages (list
      "curl"
      "ca-certificates"
      "gnupg"
      (jinja "{{ \"apt-transport-https\"
        if (ansible_distribution_release in
            [\"stretch\", \"trusty\", \"xenial\"])
        else [] }}")))
  (keyring__packages (list))
  (keyring__dependent_gpg_user "")
  (keyring__dependent_apt_auth_files (list))
  (keyring__dependent_apt_keys (list))
  (keyring__dependent_gpg_keys (list)))
