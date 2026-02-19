(playbook "debops/ansible/roles/wpcli/defaults/main.yml"
  (wpcli__base_packages (list
      "bash-completion"))
  (wpcli__packages (list))
  (wpcli__gpg_key_id "63AF 7AA1 5067 C056 16FD  DD88 A3A2 E8F2 26F0 BC06")
  (wpcli__version "2.5.0")
  (wpcli__release_files (list
      
      (url "https://github.com/wp-cli/wp-cli/releases/download/v2.2.0/wp-cli-2.2.0.phar.gpg")
      (dest (jinja "{{ wpcli__src }}") "/wp-cli-2.2.0.phar.gpg")
      (checksum "sha256:6ed3c78adea2801ce900f3dc8f09ce799958955cc842b5f8d17d8ffb74eca7a2")
      (version "2.2.0")
      
      (url "https://raw.githubusercontent.com/wp-cli/wp-cli/v2.2.0/utils/wp-completion.bash")
      (dest (jinja "{{ wpcli__src }}") "/wp-cli-2.2.0.completion.bash")
      (checksum "sha256:443ca0610ccae8d2d6aceba0ec4aa7929b87ed6cf54f666afed18d663a18a395")
      (version "2.2.0")
      
      (url "https://github.com/wp-cli/wp-cli/releases/download/v2.3.0/wp-cli-2.3.0.phar.gpg")
      (dest (jinja "{{ wpcli__src }}") "/wp-cli-2.3.0.phar.gpg")
      (checksum "sha256:24e16d96d22baec166ffb8807bf751cabd62b84e1716523f94d61b2a8d7e2255")
      (version "2.3.0")
      
      (url "https://raw.githubusercontent.com/wp-cli/wp-cli/v2.3.0/utils/wp-completion.bash")
      (dest (jinja "{{ wpcli__src }}") "/wp-cli-2.3.0.completion.bash")
      (checksum "sha256:443ca0610ccae8d2d6aceba0ec4aa7929b87ed6cf54f666afed18d663a18a395")
      (version "2.3.0")
      
      (url "https://github.com/wp-cli/wp-cli/releases/download/v2.4.0/wp-cli-2.4.0.phar.gpg")
      (dest (jinja "{{ wpcli__src }}") "/wp-cli-2.4.0.phar.gpg")
      (checksum "sha256:c009a0d9e84436eab671272ca0d0a75b5aefd1af17177c83c2b33ad945976def")
      (version "2.4.0")
      
      (url "https://raw.githubusercontent.com/wp-cli/wp-cli/v2.4.0/utils/wp-completion.bash")
      (dest (jinja "{{ wpcli__src }}") "/wp-cli-2.4.0.completion.bash")
      (checksum "sha256:443ca0610ccae8d2d6aceba0ec4aa7929b87ed6cf54f666afed18d663a18a395")
      (version "2.4.0")
      
      (url "https://github.com/wp-cli/wp-cli/releases/download/v2.5.0/wp-cli-2.5.0.phar.gpg")
      (dest (jinja "{{ wpcli__src }}") "/wp-cli-2.5.0.phar.gpg")
      (checksum "sha256:a5faf98302ac3c96f0aad38e5d1a7142cfbd28fc2df03c687094b3fbf67a19a8")
      (version "2.5.0")
      
      (url "https://raw.githubusercontent.com/wp-cli/wp-cli/v2.5.0/utils/wp-completion.bash")
      (dest (jinja "{{ wpcli__src }}") "/wp-cli-2.5.0.completion.bash")
      (checksum "sha256:443ca0610ccae8d2d6aceba0ec4aa7929b87ed6cf54f666afed18d663a18a395")
      (version "2.5.0")))
  (wpcli__src (jinja "{{ (ansible_local.fhs.src | d(\"/usr/local/src\"))
                + \"/wpcli\" }}"))
  (wpcli__binary "/usr/local/bin/wp")
  (wpcli__bash_completion "/etc/bash_completion.d/wp-completion")
  (wpcli__secure_wpconfig_enabled "True")
  (wpcli__secure_wpconfig_command "find /home /srv -type f -iname \"wp-config.php\" -perm /o+r -exec chmod -v 600 \"{}\" \\;")
  (wpcli__secure_wpconfig_interval "daily")
  (wpcli__keyring__dependent_gpg_keys (list
      (jinja "{{ wpcli__gpg_key_id }}")))
  (wpcli__php__dependent_packages (list
      "mysql")))
