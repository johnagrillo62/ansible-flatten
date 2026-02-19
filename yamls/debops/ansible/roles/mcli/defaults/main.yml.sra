(playbook "debops/ansible/roles/mcli/defaults/main.yml"
  (mcli__upstream_gpg_key "4405 F3F0 DDBA 1B9E 68A3  1D25 12C7 4390 F9AA C728")
  (mcli__upstream_type "url")
  (mcli__upstream_upgrade "False")
  (mcli__upstream_url_mirror "https://dl.min.io/client/mc/release/")
  (mcli__upstream_platform "linux-amd64")
  (mcli__upstream_url_release (jinja "{{ mcli__env_upstream_url_release }}"))
  (mcli__upstream_url_binary (jinja "{{ \"archive/mc.\" + mcli__upstream_url_release }}"))
  (mcli__upstream_git_repository "https://github.com/minio/mc")
  (mcli__upstream_git_release (jinja "{{ \"RELEASE.2019-03-20T21-29-03Z\"
                                if (ansible_distribution_release in
                                    [\"stretch\", \"buster\", \"xenial\", \"bionic\"])
                                    else (\"RELEASE.2019-09-05T23-43-50Z\"
                                      if (ansible_distribution_release in
                                          [\"bullseye\"])
                                      else mcli__upstream_url_release) }}"))
  (mcli__binary (jinja "{{ ansible_local.golang.binaries[\"mcli\"]
                   if (ansible_local.golang.binaries | d() and
                       ansible_local.golang.binaries.mcli | d())
                   else \"\" }}"))
  (mcli__golang__dependent_packages (list
      
      (name "mcli")
      (upstream_type (jinja "{{ mcli__upstream_type }}"))
      (gpg (jinja "{{ mcli__upstream_gpg_key }}"))
      (url (list
          
          (src (jinja "{{ mcli__upstream_url_mirror + mcli__upstream_platform + \"/\" + mcli__upstream_url_binary }}"))
          (dest "releases/" (jinja "{{ mcli__upstream_platform }}") "/mc/mc." (jinja "{{ mcli__upstream_url_release }}"))
          (checksum "sha256:" (jinja "{{ mcli__upstream_url_mirror + mcli__upstream_platform + \"/\" + mcli__upstream_url_binary }}") ".sha256sum")
          
          (src (jinja "{{ mcli__upstream_url_mirror + mcli__upstream_platform + \"/\" + mcli__upstream_url_binary + \".asc\" }}"))
          (dest "releases/" (jinja "{{ mcli__upstream_platform }}") "/mc/mc." (jinja "{{ mcli__upstream_url_release }}") ".asc")
          (gpg_verify "True")))
      (url_binaries (list
          
          (src "releases/" (jinja "{{ mcli__upstream_platform }}") "/mc/mc." (jinja "{{ mcli__upstream_url_release }}"))
          (dest "mcli")))
      (git (list
          
          (repo (jinja "{{ mcli__upstream_git_repository }}"))
          (version (jinja "{{ mcli__upstream_git_release }}"))
          (build_script "make clean build
")))
      (git_binaries (list
          
          (src (jinja "{{ mcli__upstream_git_repository.split(\"://\")[1] + \"/mc\" }}"))
          (dest "mcli"))))))
