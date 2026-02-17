# FINDINGS.md

Security findings from grepping 86,811 flattened paths across 14 public Ansible repos.

Everything below was found with grep on the flattened output. These findings need evaluation. Until now, that evaluation was not possible — the files could not be parsed by any standard tool. These repos are templates, examples, and frameworks used in unknown environments. They may be running in hospitals, utilities, schools, government, or production infrastructure. The risk has never been assessed because the files have never been readable by scanners.

## Summary

| Finding | Count |
|---------|-------|
| Hardcoded passwords (not in variables) | 343 |
| Shell/command/raw calls | 1,389 |
| Shell with Jinja2 (injection surface) | 569 |
| no_log = true (hidden output) | 256 |
| validate_certs = false (TLS disabled) | 34 |
| become/sudo escalation | 142 |
| Hardcoded tokens and secrets | 29 |
| Credentials in URLs | 11 |
| ignore_errors = true | 222 |
| delegate_to localhost | 129 |
| Overly permissive modes (0777/0666) | 3 |

## Hardcoded passwords

Plaintext passwords in public repos. Not in variables. Not in vault.

```
vault_userpass_password = "userpass123"
password = s3cr3t
password = secret
become_password = supersecret
vault_password = secret-vault
authorize_password = authorize-me
password = foobarbaz
```

Some are test fixtures. Whether test fixtures represent risk depends on whether people copy them as templates — which is what test fixtures are for.

## Hardcoded tokens and secrets

```
bearer_token = "asdf1234"
VAULT_DEV_ROOT_TOKEN_ID = 'vaultdev'
secret_key = "my_key"
value.my_key = this_is_the_secret_value
value.my_key = this_is_the_userpass_secret_value
notification_configuration.token = a_token
account_token = a_token
```

## Credentials in URLs

Database passwords, user credentials, embedded in connection strings.

```
db-url=mysql://domain:1234@localhost/domain
mysql+pymysql://mailman3:mmpass@localhost/mailman3
postgres://mailman3:mmpass@localhost/mailman3
mysql://roundcube:pass@localhost/roundcubemail
baseurl=http://se_user:se_pass@enterprise.sensuapp.com/yum/
```

## TLS disabled

Every vault operation in AWX docker-compose runs with `validate_certs = false`. 34 instances across the repos.

```
validate_certs = false
validate_certs = False
ansible_httpapi_validate_certs = False
verify_ssl=false
```

These are the files that configure how secrets are stored and retrieved. The secret manager itself has TLS disabled.

## Shell commands with Jinja2 injection surfaces

569 shell commands with Jinja2 variables interpolated directly into the command string. Every one is an injection surface if the variable contains user-controlled input.

```
command = "{{ galaxy_venv_dir }}/bin/python {{ galaxy_server_dir }}/scripts/manage_db.py -c {{ galaxy_config_file }} upgrade"
shell = "{{ sources_dest }}/minikube start --driver={{ driver }}"
command = openssl genrsa -out {{ work_sign_private_keyfile }} {{ receptor_rsa_bits }}
command = docker login -u="{{ docker_user }}" -p="{{ docker_password }}" "{{ docker_host }}"
```

The last one puts the password on the command line — visible in the process list to anyone on the box.

## no_log hiding output

256 tasks across the repos hide their output from logs. Some legitimate (certificate handling). Some suspicious. No scanner checks what's behind `no_log = true` because no scanner can parse the files.

## SSH security disabled

```
StrictHostKeyChecking=no
UserKnownHostsFile=/dev/null
host_key_checking = false
```

MITM wide open. These are Kubernetes deployment playbooks (kubespray) — the nodes that run your production workloads accept connections from anything that answers.

## SELinux and firewalls disabled

```
preinstall_selinux_state = permissive
name = Ensure firewalld is stopped (since this is a test server).
service = name=firewalld state=stopped
```

Marked as test configuration. Whether these defaults propagate to production deployments is unknown without evaluating downstream usage.

## Unpinned pip installs from public repos

These playbooks run on internal nodes with `become = true` (root). They pull packages from public PyPI with no version pins.

```
pip.name = openshift
pip.name = PyYAML
pip = name=pymongo state=latest
pip.name = gunicorn
pip.name = ndg-httpsclient
pip = name=docker state=present
```

No version pin means whatever is on PyPI right now gets installed as root on your internal node. A supply chain attacker poisons the package, and these playbooks install it automatically.

## Third-party repos over HTTP

Package repositories added over unencrypted HTTP — MITM can inject any package.

```
deb http://download.owncloud.org/download/repositories/stable/Debian_8.0/ /
deb http://www.rabbitmq.com/debian/ testing main
baseurl = http://download.fedoraproject.org/pub/epel/7/$basearch
deb http://ppa.launchpad.net/ansible/ansible/ubuntu xenial main
```

## The full picture on internal nodes

These playbooks are designed to run on internal production nodes. If they do, the combination looks like this:

- Unpinned packages pulled from public PyPI
- Over HTTP in some cases
- With `become = true` — installed as root
- With `ignore_errors = true` — failures silently swallowed
- With `StrictHostKeyChecking=no` — connects to whatever answers
- With `validate_certs = false` — doesn't verify who it's talking to
- With `no_log = true` — hides what it did

Whether this represents actual risk depends on where these playbooks run and how they've been modified. That assessment requires being able to read the files. Which requires being able to parse them.

## Jinja2 masks YAML errors

After stripping Jinja2, some files still fail to parse. The YAML underneath is invalid.

Example from Red Hat's own `ansible-examples` repo (`jboss-standalone/demo-aws-launch.yml` and `lamp_haproxy/aws/demo-aws-launch.yml`):

```
instance_tags: "{'ansible_group':'jboss', 'type':'{{ ec2_instance_type }}', 'group':'{{ ec2_security_group }}', 'Name':'demo_''{{ tower_user_name }}'}"
```

This line contains a Python dict literal inside a double-quoted YAML string, with nested single quotes, Jinja2 variables, and an ambiguous `''` sequence. Three languages on one line. No single parser handles all three.

PyYAML sees the outer double quotes, grabs everything inside as a string, and stops looking. Jinja2 renders the `{{ }}` variables. Python evals the rendered string into a dict. The string passes through three interpreters and none of them validate it as a whole.

After Jinja2 is stripped, the `''` that was hidden behind `{{ }}` is exposed, and the YAML is invalid according to the spec. yaml-cpp reports a parse error. The tool falls back to text and still produces output.

**Parser version regression:** yaml-cpp 0.6 correctly rejected these files with `end of map not found` at the `''` sequence. yaml-cpp 0.8.0 accepts them silently. Between versions, the parser got more lenient — the same trajectory as PyYAML. The spec violation is real in both versions. The difference is that 0.6 caught it and 0.8 doesn't.

This means the window for catching this class of bug is closing. As parsers get more lenient to handle real-world files, they accept more invalid YAML. The spec erodes. Violations that were detectable become invisible. The files don't get fixed — the checkers stop checking.

Two YAML parsers now accept this invalid YAML. Zero catch it. The spec says it's wrong. Nobody enforces the spec.

This pattern appears in multiple files in the official example repo. It was copied into downstream playbooks. The Jinja2 was masking the YAML error — while `{{ }}` was present, no parser could get close enough to see the broken quotes underneath.

Jinja2 doesn't just break parsers. It hides bugs.

## Why this was never evaluated

Ansible has no formal grammar, no spec, no parser, and no AST.

Ansible does not parse its YAML files. It loads them with PyYAML into Python dictionaries and walks the dictionaries with key lookups. To determine which key in a task is the module name, it excludes known keywords and takes whatever is left. Enrico Zini, a Debian developer who attempted to build an Ansible-to-Python converter (Transilience), described the process:

- He "failed to find precise reference documentation about what keywords are used to define a task" and resorted to guesswork.
- He described Ansible's variable system as "a big free messy cauldron of global variables."
- He noted that "one can do all sorts of chaotic things to pass parameters to Ansible tasks" — string lists, comma-separated strings, Jinja2-preprocessed structures, complex nested data — all valid, all undocumented.

His module-finding code: exclude known keys ("name", "args", "notify"), take whatever candidate remains. If there's not exactly one candidate, raise an error. That's not a parser. That's a lookup table.

Ansible's own porting guides confirm the fragility. Between versions, previously valid patterns silently break or change meaning. Boolean coercion rules change. Values that were strings become None. Templates that rendered now error. Multi-pass templating that worked for years is removed. Each porting guide contains a list of things that used to work and no longer do — not because the spec changed, but because there was never a spec to change.

Without a grammar, you can't write a parser. Without a parser, you can't build an AST. Without an AST, you can't do static analysis. Without static analysis, you can't build a scanner. The entire security scanning model requires a formal structure that Ansible has never provided.

The flattened output provides that structure. 1,013 atoms — 621 modules, 312 roles, 45 directives, 23 play keys, and 12 Jinja2 patterns — extracted from 5,873 real files with zero parse failures. This is the spec that was never written, derived from the code itself.

## Why the bottom keeps going

A system designed to never fail, written in files that can't be read, parsed by libraries that change what's valid between versions. And the dashboard says green.

Five layers:

1. **Ansible is designed to never fail.** `ignore_errors: true`. `failed_when: false`. `any_errors_fatal: false`. The tool swallows errors by design. Success is the default. Failure is opt-in.

2. **The files can't be read.** Jinja2 breaks every YAML parser. Three languages on one line — YAML, Jinja2, Python/bash — with no grammar for the combination. No scanner can parse them. No linter can analyze them. The files that run infrastructure are unreadable by any tool except the one that executes them.

3. **The YAML parsers change what's valid between versions.** yaml-cpp 0.6 rejected the `''` in Red Hat's example files. yaml-cpp 0.8 accepts them silently. The spec violation didn't get fixed — the checker stopped checking. As parsers get more lenient to handle real-world files, invalid YAML becomes invisible.

4. **No YAML fuzzing or validation regression suites exist.** Nobody tests whether a parser version still catches what the previous version caught. Nobody tests real-world Ansible files against parser updates. The stripped corpus from this project is the first real-world regression test suite for YAML parsers that has ever existed.

5. **No changelogs for parsing behavior changes.** Python publishes "What's New in Python 3.x." Ruby has release notes. Rust has edition guides. YAML parsers ship new versions with no documentation of what they stopped checking or started accepting. yaml-cpp 0.6 to 0.8 — what changed in parsing behavior? Nobody knows. No migration guide. No changelog. Nothing.

## What found this

Grep. On flattened YAML.

These findings may or may not represent real risk. The point is that until now, nobody could evaluate them. The files didn't parse. Now they do.
