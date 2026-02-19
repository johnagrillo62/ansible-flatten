(playbook "debops/ansible/roles/neurodebian/defaults/main.yml"
  (neurodebian__deploy_state "present")
  (neurodebian__upstream (jinja "{{ True
                           if (ansible_distribution_release in [\"trusty\"])
                           else False }}"))
  (neurodebian__support_packages (list
      "neurodebian"
      "netselect"))
  (neurodebian__packages (list))
  (neurodebian__group_packages (list))
  (neurodebian__host_packages (list))
  (neurodebian__dependent_packages (list))
  (neurodebian__apt_key_fingerprint "DD95 CC43 0502 E37E F840  ACEE A5D3 2F01 2649 A5A9")
  (neurodebian__apt_components (list
      "main"
      (jinja "{{ [\"contrib\", \"non-free\"]
        if (ansible_local.apt.nonfree | d() | bool)
        else [] }}")))
  (neurodebian__apt_source_types (list
      "deb"))
  (neurodebian__region (jinja "{{ ansible_local.locales.system_region | d(\"US\") }}"))
  (neurodebian__region_mirror_map 
    (AU "au")
    (CA "us-nh")
    (CN "cn-hf")
    (DE "de-m")
    (ES "de-m")
    (FR "de-md")
    (GB "de-m")
    (GR "gr")
    (IT "de-m")
    (JP "jp")
    (NZ "au")
    (PL "de-md")
    (RU "de-md")
    (US "us-nh"))
  (neurodebian__apt_mirror_map 
    (au "http://mirror.aarnet.edu.au/pub/neurodebian")
    (cn-bj1 "http://mirrors.tuna.tsinghua.edu.cn/neurodebian")
    (cn-hf "http://mirrors.ustc.edu.cn/neurodebian")
    (cn-zj "http://mirrors.zju.edu.cn/neurodebian")
    (de-m "http://neurodebian.g-node.org/")
    (de-md "http://neurodebian.ovgu.de/debian")
    (gr "http://neurobot.bio.auth.gr/neurodebian")
    (jp "http://neuroimaging.sakura.ne.jp/neurodebian")
    (us-ca "http://neurodeb.pirsquared.org/")
    (us-nh "http://neuro.debian.net/debian")
    (us-tn "http://masi.vuse.vanderbilt.edu/neurodebian"))
  (neurodebian__apt_mirror (jinja "{{ neurodebian__region_mirror_map[neurodebian__region]
                             | d(\"us-nh\") }}"))
  (neurodebian__apt_mirror_uri (jinja "{{ neurodebian__apt_mirror_map[neurodebian__apt_mirror] }}"))
  (neurodebian__apt_preferences__dependent_list (list
      
      (package "*")
      (reason "Pin NeuroDebian with priority 80 which is lower then the official Debian backports (100).
This also works when `apt_preferences__preset_list` is set which increases
Debian backports to 400 and decreases Debian testing to 50.")
      (by_role "debops.neurodebian")
      (pin "release o=NeuroDebian")
      (priority "80")
      (state (jinja "{{ \"present\" if (neurodebian__deploy_state == \"present\") else \"absent\" }}"))))
  (neurodebian__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ neurodebian__apt_key_fingerprint if neurodebian__upstream | bool else \"\" }}"))
      (state (jinja "{{ \"present\"
               if (neurodebian__deploy_state == \"present\" and
                   neurodebian__upstream | bool)
               else \"absent\" }}")))))
