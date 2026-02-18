# README_LINT.md

Lint findings from 14 public Ansible repos.

117 shell commands with unquoted Jinja2 expressions. Every one is a potential word splitting, globbing, or command injection bug. No audit caught them. No scanner caught them. No AI caught them. ansible-lint does not check for this.

## What was checked

Two patterns:

**CWE-78/SC2027 (WARNING)** — Jinja2 inside a YAML double-quoted string with escaped quotes. After YAML parsing and Jinja2 rendering, bash receives `""value""` which is unquoted. This is command injection.

**SC2086 (INFO)** — Bare Jinja2 in a shell command with no quoting at all. Word splitting and globbing risk. If the variable contains a space, the command breaks. If it contains a semicolon, it's injection.

## Results

14 repos. 117 findings.

| Repo | Files scanned | Findings |
|------|--------------|----------|
| debops | 1191 | 68 |
| kubespray | — | 18 |
| sovereign | — | 13 |
| ansible-examples | 150 | 12 |
| awx | — | 4 |
| sensu-ansible | — | 1 |
| openshift-ansible | — | 1 |

All 117 are SC2086 (bare unquoted Jinja2). Zero CWE-78/SC2027 (the double-double-quote pattern was found separately via shellcheck — see README_SHELLCHECK.md).

---

## Why unquoted variables in shell commands are bad

When bash receives an unquoted variable, three things happen:

**Word splitting.** Spaces in the value become argument separators.

```bash
file="my document.txt"
rm $file           # rm receives two arguments: "my" and "document.txt"
rm "$file"         # rm receives one argument: "my document.txt"
```

**Globbing.** Characters like `*`, `?`, `[` are expanded as file patterns.

```bash
path="backup*"
rm $path           # rm receives: backup1.tar backup2.tar backup3.tar
rm "$path"         # rm receives: "backup*" (literal)
```

**Command injection.** Characters like `;`, `|`, `&&`, backticks are executed.

```bash
input="myfile; rm -rf /"
cat $input         # runs: cat myfile  THEN  rm -rf /
cat "$input"       # runs: cat "myfile; rm -rf /" (fails safely)
```

In Ansible, the variables come from inventory, group vars, host vars, extra vars, registered output, lookups, and user input. The developer does not always control the value. The value must be quoted.

---

## Findings by category

### Cryptographic key generation — unquoted

These commands generate or manage cryptographic keys with unquoted variables. If a variable contains a space, the key is generated with wrong parameters. If it contains a semicolon, arbitrary commands run as the user generating the keys.

```bash
# sovereign — OpenVPN RSA key generation
# If {{ item }}.key contains a space, openssl writes to the wrong file
openssl genrsa -out {{ item }}.key {{ openvpn_key_size }}

# sovereign — OpenVPN Diffie-Hellman parameters
openssl dhparam -out {{ openvpn_dhparam }} {{ openvpn_key_size }}

# sovereign — OpenVPN HMAC firewall key
openvpn --genkey --secret {{ openvpn_hmac_firewall }}

# sovereign — DKIM key generation for mail
# Domain name unquoted — injection via domain name
rspamadm dkim_keygen -s default -d {{ item.name }} -k {{ item.name }}.default.key > {{ item.name }}.default.txt

# debops — boxbackup encryption key
openssl rand -out /etc/boxbackup/bbackupd/{{ boxbackup_account }}-FileEncKeys.raw
```

### Credentials on the command line — unquoted

Passwords and usernames passed as command arguments without quoting. Visible in `ps aux`. Broken by spaces. Injectable by semicolons.

```bash
# sovereign — XMPP account creation with password
# Username, domain, AND password all unquoted
prosodyctl register {{ item.name }} {{ prosody_virtual_domain }} "{{ item.password }}"

# ansible-examples — MongoDB admin password on command line
/usr/bin/mongo localhost:{{ mongos_port }}/admin -u admin -p {{ mongo_admin_pass }} /tmp/shard_init.js

# debops — LibreNMS admin account with password lookup
php adduser.php {{ item }} {{ lookup("password", secret + "/credentials/" + inventory_hostname ...) }}

# debops — SNMP credentials (four times in one file)
snmpusm -u {{ snmpd_fact_account_admin_username }} -l authPriv -a SHA -x AES ...

# debops — mosquitto password management
mosquitto_passwd -b {{ mosquitto__password_file }} {{ item.name }} ${MOSQUITTO_PASSWORD}

# ansible-examples — echoing a password
echo my password is {{my_password2}}
```

### Database management — unquoted

Commands that create, drop, or manage databases with unquoted variables. A space in a version number or cluster name breaks the command. A semicolon drops the wrong database.

```bash
# debops — drop PostgreSQL cluster
pg_dropcluster --stop {{ postgresql_server__version }} main

# debops — create PostgreSQL cluster
pg_createcluster --user={{ item.user | d(postgresql_server__user) }} ...

# debops — start PostgreSQL cluster
pg_ctlcluster {{ item.version }} {{ item.name }} start

# debops — reload PostgreSQL cluster
pg_ctlcluster {{ item.item.version }} {{ item.item.name }} reload
```

### Filesystem operations — unquoted

Commands that create, delete, copy, or unmount files with unquoted paths. A space in a path operates on the wrong file. A glob expands to unexpected files.

```bash
# kubespray — unmount with force flag
umount -f {{ item }}

# kubespray — copy files with unquoted paths
cp {{ images_dir }}/{{ item.value.filename }} {{ images_dir }}/{{ item.key }}.qcow2

# kubespray — resize disk images
qemu-img resize {{ images_dir }}/{{ item.key }}.qcow2 +8G

# sovereign — copy z-push with wildcard
cp -R z-push-{{ zpush_version }}/* /usr/share/z-push/

# sovereign — copy OpenVPN files
cp {{ openvpn_path }}/{{ item[1] }} {{ openvpn_path }}/{{ item[0] }}

# debops — touch known_hosts file
touch {{ sshd__known_hosts_file }}

# debops — install with permissions
install -o {{ redis_server__user }} -g {{ redis_server__auth_group }} -m 0640 ...

# debops — copy tinc host key
cp /etc/tinc/{{ item.value.name }}/hosts/{{ item.value.hostname }} ...
```

### Swap management — unquoted with unsafe error handling

```bash
# debops — disable swap (also SC2015: && || is not if-then-else)
test -f {{ item.path }} && swapoff {{ item.path }} || true

# debops — enable swap
swapon -p {{ item.item.priority }} {{ item.item.path }}

# debops — disable swap again
test -f {{ item.path }} && swapoff -v {{ item.path }} || true
```

The swap path is unquoted. If it contains a space, `swapoff` operates on the wrong device. The `&& ||` pattern means the `|| true` can run even when the `test` succeeds but `swapoff` fails — masking real errors.

### Network and infrastructure — unquoted

```bash
# kubespray — Azure resource group (cloud API)
az vm list-ip-addresses -o json --resource-group {{ azure_resource_group }}

# kubespray — RHEL subscription manager proxy configuration
/sbin/subscription-manager config --server.proxy_hostname={{ http_proxy | regex_replace(':\\d+$') }}

# kubespray — ping test
ping -c1 {{ main_access_ip }}

# kubespray — CoreOS cloud-init
/usr/bin/coreos-cloudinit --from-file {{ resolveconf_cloud_init_conf }}

# debops — iSCSI interface creation
iscsiadm -m iface -I {{ item }} -o new ;

# debops — check database port
nc -z localhost {{ mariadb__port }}
```

### SSH operations — unquoted

```bash
# debops — SSH fingerprint scanning (three different roles)
ssh-keyscan -H -T 10 {{ item.item }} >> {{ gitlab_runner__home + "/.ssh/known_hosts" }}
ssh-keyscan -H -T 10 {{ hostvars[item]["ansible_fqdn"] }} 2>/dev/null
ssh-keyscan -H -T 10 -p {{ item.item.ssh_port }} ...
{{ sshd__known_hosts_command }} {{ item.item }} >> {{ sshd__known_hosts_file }}
```

Unquoted hostnames and paths appended to known_hosts. If a hostname contains a space, `ssh-keyscan` scans the wrong host. The `>>` redirect with an unquoted path could append to the wrong file.

### Package management — unquoted

```bash
# debops — dpkg architecture
dpkg --add-architecture {{ item }}

# debops — update-alternatives (two different roles)
update-alternatives --auto {{ item.name }}

# debops — apt-mark
apt-mark auto {{ packages | join(' ') }}

# debops — elasticsearch plugin install/remove
bin/elasticsearch-plugin install {{ item.url | d(item.name) }} --batch
bin/elasticsearch-plugin remove {{ item.name }}

# debops — kibana plugin install/remove
bin/kibana-plugin install {{ item.url | d(item.name) }}
bin/kibana-plugin remove {{ item.name }}

# debops — dpkg signature verify
dpkg-sig --verify {{ rstudio_server__src + '/' + (rstudio_server__rstudio_deb_url | basename) }}
```

### User management — unquoted

```bash
# debops — loginctl linger (four instances across two roles)
loginctl enable-linger {{ item.name }}
loginctl disable-linger {{ item.name }}
loginctl enable-linger {{ (item.prefix | d(system_users__prefix)) + item.name }}
loginctl disable-linger {{ (item.prefix | d(system_users__prefix)) + item.name }}

# debops — usermod subuid/subgid
usermod --add-subuids {{ (item | string + "-" + ...) }}

# debops — saslauthd stop
/etc/init.d/saslauthd stop-instance saslauthd-{{ item.name }}
```

### Git operations — unquoted

```bash
# debops — git checkout (three different roles, same pattern)
git rev-parse {{ dokuwiki__git_version }}
git checkout -f {{ dokuwiki__git_version }}
git rev-parse {{ netbox__git_version }}
git checkout -f {{ netbox__git_version }}
git rev-parse {{ phpipam__git_version }}
git checkout -f {{ phpipam__git_version }}
```

Same pattern copied across three roles. Unquoted git version. If the version variable contains a space, `git checkout` checks out the wrong ref.

### Official Ansible examples — teaching the bug

```bash
# ansible-examples — delegation example
echo taking out of rotation {{inventory_hostname}}
echo hi mom {{inventory_hostname}}
echo inserting into rotation {{inventory_hostname}}

# ansible-examples — nested loops
echo "nested test a={{ item[0] }} b={{ item[1] }} c={{ item[2] }}"

# ansible-examples — prompts example
echo foo >> /tmp/{{release_version}}-alpha
echo my password is {{my_password2}}

# ansible-examples — roles example
echo just FYI, param1={{ param1 }}, param2 ={{ param2 }}

# ansible-examples — upgraded vars
echo {{ item }}

# ansible-examples — mongodb sharding
/usr/bin/mongo localhost:{{ mongos_port }}/admin -u admin -p {{ mongo_admin_pass }} /tmp/shard_init.js
```

These are the official examples. The teaching materials. The files people copy when learning Ansible. Every one has unquoted Jinja2 in shell commands. New users learn this pattern from these files and reproduce it in production.

---

## What should be done

Every `{{ }}` in a shell or command task should either:

1. Use the `| quote` filter: `{{ variable | quote }}`
2. Be inside properly quoted bash: `'{{ variable }}'` (with YAML single quotes on the outside)

Never use YAML double quotes with escaped bash quotes around Jinja2: `"echo \"{{ variable }}\""` — this creates `""value""` which is unquoted in bash (see README_SHELLCHECK.md for the full CWE-78 analysis).

ansible-lint should check for this. It does not. It has existed since 2013. It checks for YAML truthy values, trailing whitespace, line length, and missing task names. It does not check for command injection in shell commands.

---

## The fix

The fix is `| quote`. One filter. One pipe. Added to every Jinja2 expression in a shell command.

Before:
```yaml
- shell: rm {{ etcd_cert_dir }}/*{{ inventory_hostname }}*
```

After:
```yaml
- shell: rm {{ etcd_cert_dir | quote }}/*{{ inventory_hostname | quote }}*
```

117 findings. 117 fixes. Each one is adding `| quote` to a Jinja2 expression. That is the entire remediation.

> "An ounce of prevention is worth a pound of cure." — Benjamin Franklin, 1736

117 ounces. Before the pound.

