(playbook "ansible-for-devops/includes/provisioning/vars.yml"
  (drupal_core_version "8.9.x")
  (drupal_core_path "/var/www/drupal-" (jinja "{{ drupal_core_version }}") "-dev")
  (domain "drupal")
  (drupal_site_name "Drupal Test"))
