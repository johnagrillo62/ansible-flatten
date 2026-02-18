# FINDINGS.md

Security findings from grepping 14 public Ansible repos.

Everything below was found with `grep`. No scanner flagged any of it.

## Summary

| Finding | Count |
|---------|-------|
| Hardcoded passwords (not in variables) | 343 |
| Shell/command/raw calls | 345 |
| Shell with Jinja2 (injection surface) | 184 |
| no_log = true (hidden output) | 256 |
| validate_certs = false (TLS disabled) | 34 |
| become/sudo escalation | 142 |
| Hardcoded tokens and secrets | 29 |
| Credentials in URLs | 11 |
| ignore_errors = true | 222 |
| delegate_to localhost | 129 |
| Overly permissive modes (0777/0666) | 3 |

## Hardcoded passwords

Plaintext passwords in public repos. Not in variables. Not in vault. Just sitting there.

```
vault_userpass_password = "userpass123"
password = s3cr3t
password = secret
become_password = supersecret
vault_password = secret-vault
authorize_password = authorize-me
password = foobarbaz
```

Some are test fixtures. That's worse — test fixtures become templates. People copy them.

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

Database passwords and user credentials embedded in connection strings.

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

184 shell commands with Jinja2 variables interpolated directly into the command string. Every one is an injection surface if the variable contains user-controlled input.

```
shell: head -c {{ item.0.keyfile_size | d(cryptsetup__keyfile_size) }} {{ item.0.keyfile_source | d(cryptsetup__keyfile_source) }} > {{ item.0.keyfile | d(...) }}
shell: cryptsetup isLuks "{{ item.0.ciphertext_block_device }}" || cryptsetup luksFormat --batch-mode --verbose {{ ... }}
shell: sudo /usr/sbin/chpasswd 2> /dev/null
```

No quoting. No escaping. No validation. If the variable has a space or a semicolon, the command breaks or executes something else.

## no_log: hiding output

256 tasks use `no_log: true`. This hides task output from the Ansible log. Legitimate use: don't log passwords. Actual use: you can't tell.

```
no_log: '{{ not ansible_verbosity >= 3 }}'
no_log: '{{ debops__no_log | d(True) }}'
no_log: True
```

When `no_log` is itself a Jinja2 expression, the decision to hide output is made at runtime by a variable you can't see in the file.

## ignore_errors: silent failures

222 tasks use `ignore_errors: true`. The task runs, fails, and nobody knows.

```
ignore_errors: true
failed_when: false
```

Combined with shell commands and `no_log`, this means: run a command, hide the output, ignore if it fails. The trifecta of invisible execution.

## Unsafe commands found by path

With the full nested path for every value, `grep` finds things in context:

```
roundcube__default_plugins[9].options[68].value = sudo /usr/sbin/chpasswd 2> /dev/null
```

That's `sudo chpasswd` with stderr piped to `/dev/null`, inside plugin option 68 of a Roundcube webmail config, nested 9 levels deep. No scanner found it. No security audit found it. `grep passwd` found it.

---

## These files are not YAML

This is the finding underneath all the other findings.

Ansible YAML files are not YAML. They are Jinja2 templates that emit YAML. The `.yml` extension is a lie. Every tool that tries to parse them as YAML fails, because they are templates, not data.

A 35-line file from AWX — Ansible's own project — proves it:

```yaml
receptor_user: awx
{% if instance.node_type == "execution" %}
receptor_work_commands:
  ansible-runner:
    command: ansible-runner
{% endif %}
{% if listener_port %}
receptor_port: {{ listener_port }}
{% else %}
receptor_listener: false
{% endif %}
{% for peer in peers %}
  - address: {{ peer.address }}
{% endfor %}
```

No YAML parser on earth can parse this. Not yaml-cpp. Not PyYAML. Not any scanner. Not AI. The `{% if %}` controls whether entire blocks of YAML exist. The document structure itself is conditional. There is no YAML to parse until the template runs.

### Three languages in one file

Every Ansible "YAML" file can contain three languages nested inside each other:

```yaml
# YAML — the outer structure
- name: Configure app settings
  ansible.builtin.template:
    src: app.conf.j2
    # Jinja2 — expressions and control flow inside YAML values
    dest: "{{ app_config_path }}/{{ app_name }}.conf"
    owner: "{{ 'root' if ansible_os_family == 'RedHat' else 'www-data' }}"
  # Jinja2 — control flow at the structure level
  {% if enable_monitoring %}
  notify: restart monitoring
  {% endif %}
  vars:
    # Python dict literal — inside Jinja2, inside a YAML value
    connection_opts: "{{ {'host': db_host, 'port': db_port, 'ssl': {'verify': True, 'ca': ca_path}} | to_json }}"
```

Three grammars. Three parsers needed. Nested inside each other. In a file called `.yml`.

A YAML parser chokes on the Jinja2. A Jinja2 parser doesn't understand the YAML structure. Neither of them can read the Python dict literal inside the `{{ }}` expression. And the Python dict contains nested dicts, so `}}` appears inside the expression — you need brace-depth counting just to find where the Jinja2 ends and the YAML resumes.

No tool handles all three. The scanners handle zero. They try to parse YAML, hit Jinja2, and skip the file entirely.

### "Infrastructure as Code" with no code toolchain

They called it "Infrastructure as Code." But:

- Where's the compiler? Ansible renders at runtime.
- Where's the type checker? There isn't one.
- Where's the static analysis? The scanners skip the files.
- Where's the test suite? They test by deploying.

They got the name right and everything else wrong. They said "code" and treated it like config.

### It used to be YAML

In 2012, Ansible playbooks were YAML. Plain keys and values. Then someone added `{{ variable }}`. Then `{% if %}`. Then `{% for %}`. Then Jinja2 filters, macros, nested dicts. One feature at a time. Each step looked like the last one. Nobody changed the file extension. Nobody updated the tools. Nobody told the scanners.

14 years of one degree at a time.

---

## AI does not parse

Every AI code review tool — Copilot, CodeWhisperer, LLM-based scanners — is a pattern matcher. Not a parser.

AI does not build ASTs. It does not track grammar state. It does not verify structure. It reads the file the same way it reads English: by predicting what comes next based on training data.

This means:

- AI cannot tell you it failed to parse a file. It just guesses.
- AI was trained on these same repos. Hardcoded passwords are the pattern it learned. It doesn't flag them because they look normal.
- AI processes one file at a time in a context window. It cannot grep across 2383 files. It cannot cross-reference. It cannot search.
- AI is slow and expensive per file. A tool runs in seconds for free.

The industry is moving from scanners that can't parse the files to AI that can't parse the files but costs more.

`grep` doesn't hallucinate. `grep` doesn't guess. `grep` finds `password = s3cr3t` or it doesn't.

---

## Reproduce

```bash
grep -r password *.yml
```

That one command is a security audit.

## The limitation

Nobody has ever parsed these files as YAML. Not Ansible. Not any tool. Ansible renders the Jinja2 first — replaces expressions with real values — and only then parses the result as YAML. The raw files were never parsed as YAML by anything. They can't be. They're templates.

Not all Jinja2 templates can be converted back to YAML. When `{% if %}`, `{% for %}`, or `{% else %}` control the document structure — deciding whether entire blocks of YAML exist — no YAML parser can handle the file. The structure itself is conditional. There is no YAML until the template runs with real variables.

Out of 2383 files across 14 repos, 3 had this problem. Three files where the Jinja2 is structural, not just value-level. The other 2380 files strip cleanly to valid YAML.

99.87% of Ansible files are templates with blanks. Fill in the blanks with placeholders, you get valid YAML, you get a tree, you get paths, you get grep. The remaining 0.13% have structural Jinja2 — `{% if %}` and `{% for %}` controlling the document shape. They need the Jinja2 engine to resolve. Or they need fallback text parsing — which still finds things no scanner finds.
