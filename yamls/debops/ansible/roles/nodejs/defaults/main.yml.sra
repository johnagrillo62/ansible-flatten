(playbook "debops/ansible/roles/nodejs/defaults/main.yml"
  (nodejs__distribution_release (jinja "{{ ansible_local.core.distribution_release | d(ansible_distribution_release) }}"))
  (nodejs__node_upstream (jinja "{{ ansible_local.nodejs.node_upstream
                            | d(nodejs__distribution_release in [\"xenial\"]) | bool }}"))
  (nodejs__node_upstream_release (jinja "{{ \"node_8.x\"
                                   if (nodejs__distribution_release in
                                       [\"stretch\", \"trusty\",
                                        \"xenial\", \"bionic\"])
                                   else \"node_10.x\" }}"))
  (nodejs__node_upstream_key_id "9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280")
  (nodejs__node_upstream_repository "deb https://deb.nodesource.com/" (jinja "{{ nodejs__node_upstream_release }}") " " (jinja "{{ nodejs__distribution_release }}") " main")
  (nodejs__yarn_upstream (jinja "{{ True
                           if nodejs__node_upstream | bool
                           else (ansible_local.nodejs.yarn_upstream
                                  | d(nodejs__distribution_release in
                                    [\"stretch\", \"xenial\", \"bionic\"])) }}"))
  (nodejs__yarn_upstream_key_id "72ECF46A56B4AD39C907BBB71646B01B86E50310")
  (nodejs__yarn_upstream_repository "deb https://dl.yarnpkg.com/debian/ stable main")
  (nodejs__remove_packages (list
      "cmdtest"
      (jinja "{{ \"yarnpkg\" if nodejs__yarn_upstream | bool else [] }}")))
  (nodejs__base_packages (list
      "nodejs"
      (jinja "{{ [] if nodejs__node_upstream | bool else \"npm\" }}")
      (jinja "{{ \"yarn\"
        if nodejs__yarn_upstream | bool
        else ([]
              if (nodejs__distribution_release in
                  [\"stretch\", \"trusty\",
                   \"xenial\", \"bionic\"])
              else \"yarnpkg\") }}")))
  (nodejs__packages (list))
  (nodejs__group_packages (list))
  (nodejs__host_packages (list))
  (nodejs__dependent_packages (list))
  (nodejs__npm_packages (list))
  (nodejs__npm_group_packages (list))
  (nodejs__npm_host_packages (list))
  (nodejs__npm_dependent_packages (list))
  (nodejs__npm_production_mode "True")
  (nodejs__apt_preferences__dependent_list (list
      
      (packages (list
          "nodejs"
          "nodejs-*"
          "node-*"
          "libssl1.0.0"
          "libssl-dev"
          "npm"
          "libuv1"
          "libuv1-dev"))
      (backports (list
          "stretch"))
      (reason "Unsupported NodeJS version, parity with next Debian release")
      (by_role "debops_nodejs")
      (filename "debops_nodejs.pref")
      (state (jinja "{{ \"absent\" if nodejs__node_upstream | bool else \"present\" }}"))
      
      (package "*")
      (pin "origin \"deb.nodesource.com\"")
      (priority "100")
      (reason "Don't upgrade software automatically using packages from external repository")
      (role "debops.nodejs")
      (suffix "_deb_nodesource_com")
      (state (jinja "{{ \"present\" if nodejs__node_upstream | bool else \"absent\" }}"))
      
      (packages (list
          "nodejs"
          "nodejs-*"))
      (pin "origin \"deb.nodesource.com\"")
      (priority "501")
      (reason "Prefer nodejs packages from the same repository for consistency")
      (role "debops.nodejs")
      (suffix "_deb_nodesource_com")
      (state (jinja "{{ \"present\" if nodejs__node_upstream | bool else \"absent\" }}"))))
  (nodejs__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ nodejs__node_upstream_key_id }}"))
      (repo (jinja "{{ nodejs__node_upstream_repository }}"))
      (state (jinja "{{ \"present\" if nodejs__node_upstream | bool else \"absent\" }}"))
      
      (id (jinja "{{ nodejs__yarn_upstream_key_id }}"))
      (repo (jinja "{{ nodejs__yarn_upstream_repository }}"))
      (state (jinja "{{ \"present\" if nodejs__yarn_upstream | bool else \"absent\" }}")))))
