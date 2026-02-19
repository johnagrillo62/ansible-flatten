(playbook "awx/main/tests/data/projects/host_query/extensions/audit/event_query.yml"
  (demo.query.example 
    (query "{name: .name, canonical_facts: {host_name: .direct_host_name}, facts: {device_type: .device_type}}")))
