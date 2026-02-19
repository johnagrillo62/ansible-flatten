(playbook "awx_collection/tools/vars/aliases.yml"
  (aliases 
    (job_templates 
      (ask_tags_on_launch (list
          "ask_tags"))
      (ask_verbosity_on_launch (list
          "ask_verbosity"))
      (ask_diff_mode_on_launch (list
          "ask_diff_mode"))
      (allow_simultaneous (list
          "concurrent_jobs_enabled"))
      (diff_mode (list
          "diff_mode_enabled"))
      (ask_inventory_on_launch (list
          "ask_inventory"))
      (limit (list
          "ask_limit"))
      (force_handlers (list
          "force_handlers_enabled"))
      (ask_job_type_on_launch (list
          "ask_job_type"))
      (ask_skip_tags_on_launch (list
          "ask_skip_tags"))
      (use_fact_cache (list
          "fact_caching_enabled"))
      (extra_vars (list
          "ask_extra_vars"))
      (ask_credential_on_launch (list
          "ask_credential")))))
