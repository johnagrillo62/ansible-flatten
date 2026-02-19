(playbook "awx_collection/tools/roles/template_galaxy/tasks/main.yml"
  (tasks
    (task "Sanity assertions, that some variables have a non-blank value"
      (assert 
        (that (list
            "collection_version is defined and collection_version | length > 0"
            "collection_package is defined and collection_package | length > 0"
            "collection_path is defined and collection_path | length > 0"))))
    (task "Set the collection version in the controller_api.py file"
      (replace 
        (path (jinja "{{ collection_path }}") "/plugins/module_utils/controller_api.py")
        (regexp "^    _COLLECTION_VERSION = \"0.0.1-devel\"")
        (replace "    _COLLECTION_VERSION = \"" (jinja "{{ collection_version }}") "\""))
      (when (list
          "awx_template_version | default(True)")))
    (task "Set the collection type in the controller_api.py file"
      (replace 
        (path (jinja "{{ collection_path }}") "/plugins/module_utils/controller_api.py")
        (regexp "^    _COLLECTION_TYPE = \"awx\"")
        (replace "    _COLLECTION_TYPE = \"" (jinja "{{ collection_package }}") "\"")))
    (task "Do file content replacements for non-default namespace or package name"
      (block (list
          
          (name "Change module doc_fragments to support desired namespace and package names")
          (replace 
            (path (jinja "{{ item }}"))
            (regexp "^extends_documentation_fragment: awx.awx.auth([a-zA-Z0-9_]*)$")
            (replace "extends_documentation_fragment: " (jinja "{{ collection_namespace }}") "." (jinja "{{ collection_package }}") ".auth\\1"))
          (with_fileglob (list
              (jinja "{{ collection_path }}") "/plugins/inventory/*.py"
              (jinja "{{ collection_path }}") "/plugins/lookup/*.py"
              (jinja "{{ collection_path }}") "/plugins/modules/*.py"))
          (loop_control 
            (label (jinja "{{ item | basename }}")))
          
          (name "Change inventory file to support desired namespace and package names")
          (replace 
            (path (jinja "{{ collection_path }}") "/plugins/inventory/controller.py")
            (regexp "^    NAME = 'awx.awx.controller'  # REPLACE$")
            (replace "    NAME = '" (jinja "{{ collection_namespace }}") "." (jinja "{{ collection_package }}") ".controller'  # REPLACE"))
          
          (name "Change runtime.yml redirect destinations")
          (replace 
            (path (jinja "{{ collection_path }}") "/meta/runtime.yml")
            (regexp "awx.awx.")
            (replace (jinja "{{ collection_namespace }}") "." (jinja "{{ collection_package }}") "."))
          
          (name "get list of test files")
          (find 
            (paths (jinja "{{ collection_path }}") "/tests/integration/targets/")
            (recurse "true"))
          (register "test_files")
          
          (name "Change lookup plugin fqcn usage in tests")
          (replace 
            (path (jinja "{{ item.path }}"))
            (regexp "awx.awx")
            (replace (jinja "{{ collection_namespace }}") "." (jinja "{{ collection_package }}")))
          (loop (jinja "{{ test_files.files }}"))
          
          (name "Get sanity tests to work with non-default name")
          (lineinfile 
            (path (jinja "{{ collection_path }}") "/tests/sanity/ignore-2.10.txt")
            (state "absent")
            (regexp " pylint:wrong-collection-deprecated-version-tag$"))))
      (when (list
          "(collection_package != 'awx') or (collection_namespace != 'awx')")))
    (task "Template the galaxy.yml file"
      (template 
        (src (jinja "{{ collection_path }}") "/tools/roles/template_galaxy/templates/galaxy.yml.j2")
        (dest (jinja "{{ collection_path }}") "/galaxy.yml")
        (force "true")))
    (task "Template the README.md file"
      (template 
        (src (jinja "{{ collection_path }}") "/tools/roles/template_galaxy/templates/README.md.j2")
        (dest (jinja "{{ collection_path }}") "/README.md")
        (force "true")))))
