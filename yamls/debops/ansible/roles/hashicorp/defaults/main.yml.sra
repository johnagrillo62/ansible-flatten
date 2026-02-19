(playbook "debops/ansible/roles/hashicorp/defaults/main.yml"
  (hashicorp__base_packages (list
      "rsync"
      "openssl"
      "ca-certificates"
      "unzip"))
  (hashicorp__packages (list))
  (hashicorp__dependent_packages (list))
  (hashicorp__user "hashicorp")
  (hashicorp__group "hashicorp")
  (hashicorp__home (jinja "{{ (ansible_local.fhs.home | d(\"/var/local\"))
                     + \"/\" + hashicorp__user }}"))
  (hashicorp__comment "HashiCorp Application Manager")
  (hashicorp__shell "/usr/sbin/nologin")
  (hashicorp__gpg_key_id "C874 011F 0AB4 0511 0D02 1055 3436 5D94 72D7 468F")
  (hashicorp__keyserver (jinja "{{ ansible_local.keyring.keyserver | d(\"hkp://keyserver.ubuntu.com\") }}"))
  (hashicorp__applications (list))
  (hashicorp__dependent_applications (list))
  (hashicorp__default_version_map 
    (atlas-upload-cli "0.2.0")
    (consul "0.8.3")
    (consul-replicate "0.3.1")
    (consul-template "0.18.3")
    (docker-base "0.0.4")
    (docker-basetool "0.0.3")
    (envconsul "0.6.2")
    (nomad "0.5.6")
    (otto "0.2.0")
    (packer "1.0.0")
    (serf "0.8.1")
    (terraform "0.9.5")
    (vault "0.7.2")
    (vault-ssh-helper "0.1.3"))
  (hashicorp__version_map )
  (hashicorp__combined_version_map (jinja "{{ hashicorp__default_version_map
                                     | combine(hashicorp__version_map) }}"))
  (hashicorp__default_binary_map 
    (atlas-upload-cli "atlas-upload")
    (docker-base (list
        "bin/dumb-init"
        "bin/gosu")))
  (hashicorp__binary_map )
  (hashicorp__combined_binary_map (jinja "{{ hashicorp__default_binary_map
                                    | combine(hashicorp__binary_map) }}"))
  (hashicorp__src (jinja "{{ (ansible_local.fhs.src | d(\"/usr/local/src\"))
                    + \"/\" + hashicorp__user + \"/\" +
                     (hashicorp__base_url.split(\"://\") | last | split(\"/\") | first) }}"))
  (hashicorp__lib (jinja "{{ (ansible_local.fhs.lib | d(\"/usr/local/lib\"))
                    + \"/\" + hashicorp__user }}"))
  (hashicorp__bin (jinja "{{ ansible_local.fhs.bin | d(\"/usr/local/bin\") }}"))
  (hashicorp__base_url "https://releases.hashicorp.com/")
  (hashicorp__platform (jinja "{{ ansible_system | lower }}"))
  (hashicorp__architecture (jinja "{{ ansible_architecture }}"))
  (hashicorp__architecture_map 
    (x86_64 "amd64")
    (i386 "386")
    (armhf "arm"))
  (hashicorp__tar_suffix (jinja "{{ hashicorp__platform + \"_\"
                           + hashicorp__architecture_map[hashicorp__architecture]
                           + \".zip\" }}"))
  (hashicorp__hash_suffix "SHA256SUMS")
  (hashicorp__sig_suffix (jinja "{{ hashicorp__hash_suffix + \".sig\" }}"))
  (hashicorp__consul_webui (jinja "{{ ansible_local.hashicorp.consul_webui | d(False) | bool }}"))
  (hashicorp__consul_webui_suffix "web_ui.zip")
  (hashicorp__consul_webui_path (jinja "{{ ansible_local.nginx.www | d(\"/srv/www\") + \"/consul/sites/public\" }}"))
  (hashicorp__keyring__dependent_gpg_keys (list
      
      (user (jinja "{{ hashicorp__user }}"))
      (group (jinja "{{ hashicorp__group }}"))
      (home (jinja "{{ hashicorp__home }}"))
      (id (jinja "{{ hashicorp__gpg_key_id }}"))
      (state (jinja "{{ \"present\"
               if (hashicorp__applications or hashicorp__dependent_applications)
               else \"absent\" }}"))
      
      (user (jinja "{{ hashicorp__user }}"))
      (id "91A6 E7F8 5D05 C656 30BE F189 5185 2D87 348F FC4C")
      (state "absent"))))
