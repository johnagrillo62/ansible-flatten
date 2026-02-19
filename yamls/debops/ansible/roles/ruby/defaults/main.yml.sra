(playbook "debops/ansible/roles/ruby/defaults/main.yml"
  (ruby__base_packages (list
      "ruby"
      "libruby"
      "rubygems-integration"
      "ruby-bundler"))
  (ruby__dev_packages (jinja "{{ [\"ruby-dev\", \"build-essential\"]
	                if (ruby__dev_support | bool or
	                    ruby__gems or ruby__group_gems or
	                    ruby__host_gems or ruby__dependent_gems or
	                    ruby__user_gems or ruby__group_user_gems or
	                    ruby__host_user_gems or ruby__dependent_user_gems)
	                else [] }}"))
  (ruby__dev_support "False")
  (ruby__packages (list))
  (ruby__group_packages (list))
  (ruby__host_packages (list))
  (ruby__dependent_packages (list))
  (ruby__gems (list))
  (ruby__group_gems (list))
  (ruby__host_gems (list))
  (ruby__dependent_gems (list))
  (ruby__user_gems (list))
  (ruby__group_user_gems (list))
  (ruby__host_user_gems (list))
  (ruby__dependent_user_gems (list)))
