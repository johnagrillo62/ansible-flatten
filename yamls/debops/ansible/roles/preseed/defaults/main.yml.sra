(playbook "debops/ansible/roles/preseed/defaults/main.yml"
  (preseed__subdomain "seed")
  (preseed__base_domain (jinja "{{ preseed__subdomain + \".\" + ansible_domain }}"))
  (preseed__domains (list
      (jinja "{{ preseed__base_domain }}")
      (jinja "{{ preseed__base_domain | split(\".\") | first }}")
      (jinja "{{ \"~^(?<preseed>.+)\\.\" + preseed__base_domain | replace(\".\", \"\\.\") + \"$\" }}")
      (jinja "{{ \"~^(?<preseed>.+)\\.\" + ansible_domain | replace(\".\", \"\\.\") + \"$\" }}")
      (jinja "{{ \"~^(?<preseed>.+)\\.\" + preseed__subdomain | replace(\".\", \"\\.\") + \"$\" }}")
      (jinja "{{ \"~^(?<preseed>.+)$\" }}")))
  (preseed__www (jinja "{{ (ansible_local.fhs.www | d(\"/srv/www\"))
                  + \"/sites/debian-preseed/public\" }}"))
  (preseed__root_sshkeys (list
      (jinja "{{ lookup(\"pipe\", \"ssh-add -L | grep ^\\\\\\(sk-\\\\\\)\\\\\\?ssh || cat ~/.ssh/*.pub || cat ~/.ssh/authorized_keys || true\") }}")))
  (preseed__admin_name "ansible")
  (preseed__admin_fullname "Ansible Control User")
  (preseed__admin_sshkeys (list
      (jinja "{{ lookup(\"pipe\", \"ssh-add -L | grep ^\\\\\\(sk-\\\\\\)\\\\\\?ssh || cat ~/.ssh/*.pub || cat ~/.ssh/authorized_keys || true\") }}")))
  (preseed__debian_postinst_commands "")
  (preseed__debian_packages (list
      "python3"
      "python3-apt"
      "python3-pip"
      "python3-debian"
      "lsb-release"
      "git"
      "curl"))
  (preseed__debian_kernel_arguments (list
      "cgroup_enable=memory"
      "swapaccount=1"))
  (preseed__debian_password_length "32")
  (preseed__debian_root_password (jinja "{{ lookup('password', secret + '/credentials/' + inventory_hostname
                                          + '/preseed/debian/root/password '
                                          + 'encrypt=sha512_crypt length=' + preseed__debian_password_length) }}"))
  (preseed__debian_admin_password (jinja "{{ lookup('password', secret + '/credentials/' + inventory_hostname
                                           + '/preseed/debian/' + preseed__admin_name + '/password '
                                           + 'encrypt=sha512_crypt length=' + preseed__debian_password_length) }}"))
  (preseed__default_definitions (list
      
      (name "debian-stretch")
      (flavor "debian")
      (release "stretch")
      (options (jinja "{{ preseed__options_interactive_partman
                 + preseed__options_enable_nonfree }}"))
      
      (name "debian-buster")
      (flavor "debian")
      (release "buster")
      (options (jinja "{{ preseed__options_interactive_partman
                 + preseed__options_enable_nonfree }}"))
      
      (name "debian-bullseye")
      (flavor "debian")
      (release "bullseye")
      (options (jinja "{{ preseed__options_interactive_partman
                 + preseed__options_enable_nonfree }}"))
      
      (name "debian-bookworm")
      (flavor "debian")
      (release "bookworm")
      (options (jinja "{{ preseed__options_interactive_partman
                 + preseed__options_enable_nonfree }}"))
      
      (name "debian-trixie")
      (flavor "debian")
      (release "trixie")
      (options (jinja "{{ preseed__options_interactive_partman
                 + preseed__options_enable_nonfree }}"))
      
      (name "debian-stretch-user")
      (flavor "debian-user")
      (release "stretch")
      (options (jinja "{{ preseed__options_interactive_partman
                 + preseed__options_ansible_user
                 + preseed__options_enable_nonfree }}"))
      (admin_username (jinja "{{ preseed__admin_name }}"))
      
      (name "debian-buster-user")
      (flavor "debian-user")
      (release "buster")
      (options (jinja "{{ preseed__options_interactive_partman
                 + preseed__options_ansible_user
                 + preseed__options_enable_nonfree }}"))
      (admin_username (jinja "{{ preseed__admin_name }}"))
      
      (name "debian-bullseye-user")
      (flavor "debian-user")
      (release "bullseye")
      (options (jinja "{{ preseed__options_interactive_partman
                 + preseed__options_ansible_user
                 + preseed__options_enable_nonfree }}"))
      (admin_username (jinja "{{ preseed__admin_name }}"))
      
      (name "debian-bookworm-user")
      (flavor "debian-user")
      (release "bookworm")
      (options (jinja "{{ preseed__options_interactive_partman
                 + preseed__options_ansible_user
                 + preseed__options_enable_nonfree }}"))
      (admin_username (jinja "{{ preseed__admin_name }}"))
      
      (name "debian-trixie-user")
      (flavor "debian-user")
      (release "trixie")
      (options (jinja "{{ preseed__options_interactive_partman
                 + preseed__options_ansible_user
                 + preseed__options_enable_nonfree }}"))
      (admin_username (jinja "{{ preseed__admin_name }}"))
      
      (name "debian-stretch-vm")
      (flavor "debian-vm")
      (release "stretch")
      
      (name "debian-buster-vm")
      (flavor "debian-vm")
      (release "buster")
      
      (name "debian-bullseye-vm")
      (flavor "debian-vm")
      (release "bullseye")
      
      (name "debian-bookworm-vm")
      (flavor "debian-vm")
      (release "bookworm")
      
      (name "debian-trixie-vm")
      (flavor "debian-vm")
      (release "trixie")
      
      (name "debian-stretch-vm-user")
      (flavor "debian-vm-user")
      (release "stretch")
      (options (jinja "{{ preseed__options_ansible_user }}"))
      (admin_username (jinja "{{ preseed__admin_name }}"))
      
      (name "debian-buster-vm-user")
      (flavor "debian-vm-user")
      (release "buster")
      (options (jinja "{{ preseed__options_ansible_user }}"))
      (admin_username (jinja "{{ preseed__admin_name }}"))
      
      (name "debian-bullseye-vm-user")
      (flavor "debian-vm-user")
      (release "bullseye")
      (options (jinja "{{ preseed__options_ansible_user }}"))
      (admin_username (jinja "{{ preseed__admin_name }}"))
      
      (name "debian-bookworm-vm-user")
      (flavor "debian-vm-user")
      (release "bookworm")
      (options (jinja "{{ preseed__options_ansible_user }}"))
      (admin_username (jinja "{{ preseed__admin_name }}"))
      
      (name "debian-trixie-vm-user")
      (flavor "debian-vm-user")
      (release "trixie")
      (options (jinja "{{ preseed__options_ansible_user }}"))
      (admin_username (jinja "{{ preseed__admin_name }}"))))
  (preseed__definitions (list))
  (preseed__group_definitions (list))
  (preseed__host_definitions (list))
  (preseed__combined_definitions (jinja "{{ preseed__default_definitions
                                   + preseed__definitions
                                   + preseed__group_definitions
                                   + preseed__host_definitions }}"))
  (preseed__original_configuration (list
      
      (name "comment_contents")
      (comment "Contents of the preconfiguration file (for ${flavor} on ${release})")
      (state "hidden")
      
      (name "debian-installer/locale")
      (comment "Localization
Preseeding only locale sets language, country and locale
")
      (value "en_US")
      
      (name "debian-installer/language")
      (comment "The values can also be preseeded individually for greater flexibility.")
      (value "en")
      (state "comment")
      
      (name "debian-installer/country")
      (value "NL")
      (state "comment")
      
      (name "comment_debian-installer/locale")
      (option "debian-installer/locale")
      (value "en_GB.UTF-8")
      (state "comment")
      
      (name "localechooser/supported-locales")
      (comment "Optionally specify additional locales to be generated.")
      (type "multiselect")
      (value "en_US.UTF-8, nl_NL.UTF-8")
      (state "comment")
      
      (name "keyboard-configuration/xkb-keymap")
      (comment "Keyboard selection.")
      (type "select")
      (value "us")
      
      (name "keyboard-configuration/toggle")
      (type "select")
      (value "No toggling")
      (state "comment")
      
      (name "netcfg/enable")
      (comment "Network configuration
Disable network configuration entirely. This is useful for cdrom
installations on non-networked devices where the network questions,
warning and long timeouts are a nuisance.
")
      (value "False")
      (state "comment")
      
      (name "netcfg/choose_interface")
      (comment "netcfg will choose an interface that has link if possible. This makes it
skip displaying a list if there is more than one interface.
")
      (type "select")
      (value "auto")
      
      (name "comment_netcfg/choose_interface")
      (option "netcfg/choose_interface")
      (comment "To pick a particular interface instead:")
      (type "select")
      (value "eth1")
      (state "comment")
      
      (name "netcfg/link_wait_timeout")
      (comment "To set a different link detection timeout (default is 3 seconds).
Values are interpreted as seconds.
")
      (value "10")
      (state "comment")
      
      (name "netcfg/dhcp_timeout")
      (comment "If you have a slow dhcp server and the installer times out waiting for
it, this might be useful.
")
      (value "60")
      (state "comment")
      
      (name "netcfg/dhcpv6_timeout")
      (value "60")
      (state "comment")
      
      (name "netcfg/disable_autoconfig")
      (comment "If you prefer to configure the network manually, uncomment this line and
the static network configuration below.
")
      (value "True")
      (state "comment")
      
      (name "netcfg/dhcp_failed")
      (comment "If you want the preconfiguration file to work on systems both with and
without a dhcp server, uncomment these lines and the static network
configuration below.
")
      (type "note")
      (state "comment")
      
      (name "netcfg/dhcp_options")
      (type "select")
      (value "Configure network manually")
      (state "comment")
      
      (name "netcfg/get_ipaddress")
      (comment "Static network configuration.
IPv4 example
")
      (value "192.0.2.42")
      (state "comment")
      
      (name "netcfg/get_netmask")
      (value "255.255.255.0")
      (state "comment")
      
      (name "netcfg/get_gateway")
      (value "192.0.2.1")
      (state "comment")
      
      (name "netcfg/get_nameservers")
      (value "192.0.2.1")
      (state "comment")
      
      (name "netcfg/confirm_static")
      (value "True")
      (state "comment")
      
      (name "ipv6_netcfg/get_ipaddress")
      (comment "IPv6 example")
      (option "netcfg/get_ipaddress")
      (value "2001:db8::2")
      (state "comment")
      
      (name "ipv6_netcfg/get_netmask")
      (option "netcfg/get_netmask")
      (value "ffff:ffff:ffff:ffff::")
      (state "comment")
      
      (name "ipv6_netcfg/get_gateway")
      (option "netcfg/get_gateway")
      (value "2001:db8::1")
      (state "comment")
      
      (name "ipv6_netcfg/get_nameservers")
      (option "netcfg/get_nameservers")
      (value "2001:db8::1")
      (state "comment")
      
      (name "ipv6_netcfg/confirm_static")
      (option "netcfg/confirm_static")
      (value "True")
      (state "comment")
      
      (name "netcfg/get_hostname")
      (comment "Any hostname and domain names assigned from dhcp take precedence over
values set here. However, setting the values still prevents the questions
from being shown, even if values come from dhcp.
")
      (value "unassigned-hostname")
      
      (name "netcfg/get_domain")
      (value "unassigned-domain")
      
      (name "netcfg/hostname")
      (comment "If you want to force a hostname, regardless of what either the DHCP
server returns or what the reverse DNS entry for the IP is, uncomment
and adjust the following line.
")
      (value "somehost")
      (state "comment")
      
      (name "netcfg/wireless_wep")
      (comment "Disable that annoying WEP key dialog.")
      (value "")
      
      (name "netcfg/dhcp_hostname")
      (comment "The wacky dhcp hostname that some ISPs use as a password of sorts.
")
      (value "radish")
      (state "comment")
      
      (name "hw-detect/load_firmware")
      (comment "If non-free firmware is needed for the network or other hardware, you can
configure the installer to always try to load it, without prompting. Or
change to false to disable asking.
")
      (value "True")
      (state "comment")
      
      (name "anna/choose_modules")
      (comment "Network console
Use the following settings if you wish to make use of the network-console
component for remote installation over SSH. This only makes sense if you
intend to perform the remainder of the installation manually.
")
      (value "network-console")
      (state "comment")
      
      (name "network-console/authorized_keys_url")
      (value "http://192.0.2.1/openssh-key")
      (state "comment")
      
      (name "network-console/password")
      (type "password")
      (value "r00tme")
      (state "comment")
      
      (name "network-console/password-again")
      (type "password")
      (value "r00tme")
      (state "comment")
      
      (name "mirror/protocol")
      (comment "Mirror settings
If you select ftp, the mirror/country string does not need to be set.
")
      (value "ftp")
      (state "comment")
      
      (name "mirror/country")
      (value "manual")
      
      (name "mirror/http/hostname")
      (value "http.us.debian.org")
      
      (name "mirror/http/directory")
      (value "/debian")
      
      (name "mirror/http/proxy")
      (value "")
      
      (name "mirror/suite")
      (comment "Suite to install.")
      (value "testing")
      (state "comment")
      
      (name "mirror/udeb/suite")
      (comment "Suite to use for loading installer components (optional)")
      (value "testing")
      (state "comment")
      
      (name "passwd/root-login")
      (comment "Account setup
Skip creation of a root account (normal user account will be able to
use sudo).
")
      (value "False")
      (state "comment")
      
      (name "passwd/make-user")
      (comment "Alternatively, to skip creation of a normal user account.")
      (value "False")
      (state "comment")
      
      (name "passwd/root-password")
      (comment "Root password, either in clear text")
      (type "password")
      (value "r00tme")
      (state "comment")
      
      (name "passwd/root-password-again")
      (type "password")
      (value "r00tme")
      (state "comment")
      
      (name "passwd/root-password-crypted")
      (comment "or encrypted using a crypt(3) hash.")
      (type "password")
      (value "[crypt(3) hash]")
      (state "comment")
      
      (name "passwd/user-fullname")
      (comment "To create a normal user account.")
      (value "Debian User")
      (state "comment")
      
      (name "passwd/username")
      (value "debian")
      (state "comment")
      
      (name "passwd/user-password")
      (comment "Normal user's password, either in clear text")
      (type "password")
      (value "insecure")
      (state "comment")
      
      (name "passwd/user-password-again")
      (type "password")
      (value "insecure")
      (state "comment")
      
      (name "passwd/user-password-crypted")
      (comment "or encrypted using a crypt(3) hash.")
      (type "password")
      (value "[crypt(3) hash]")
      (state "comment")
      
      (name "passwd/user-uid")
      (comment "Create the first user with the specified UID instead of the default.")
      (value "1010")
      (state "comment")
      
      (name "passwd/user-default-groups")
      (comment "The user account will be added to some standard initial groups.
To override that, use this.
")
      (value (list
          "audio"
          "cdrom"
          "video"))
      (state "comment")
      
      (name "clock-setup/utc")
      (comment "Clock and time zone setup
Controls whether or not the hardware clock is set to UTC.
")
      (value "True")
      
      (name "time/zone")
      (comment "You may set this to any valid setting for $TZ; see the contents of
/usr/share/zoneinfo/ for valid values.
")
      (value "US/Eastern")
      
      (name "clock-setup/ntp")
      (comment "Controls whether to use NTP to set the clock during the install")
      (value "True")
      
      (name "clock-setup/ntp-server")
      (comment "NTP server to use. The default is almost always fine here.")
      (value "ntp.example.com")
      (state "comment")
      
      (name "partman-auto/init_automatically_partition")
      (comment "Partitioning
If the system has free space you can choose to only partition that space.
This is only honoured if partman-auto/method (below) is not set.
")
      (type "select")
      (value "biggest_free")
      (state "comment")
      
      (name "partman-auto/disk")
      (comment "Alternatively, you may specify a disk to partition. If the system has only
one disk the installer will default to using that, but otherwise the device
name must be given in traditional, non-devfs format (so e.g. /dev/sda
and not e.g. /dev/discs/disc0/disc).
For example, to use the first SCSI/SATA hard disk:
")
      (value "/dev/sda")
      (state "comment")
      
      (name "partman-auto/method")
      (comment "In addition, you'll need to specify the method to use.
The presently available methods are:
- regular: use the usual partition types for your architecture
- lvm:     use LVM to partition the disk
- crypto:  use LVM within an encrypted partition
")
      (value "lvm")
      
      (name "partman-auto-lvm/guided_size")
      (comment "You can define the amount of space that will be used for the LVM volume
group. It can either be a size with its unit (eg. 20 GB), a percentage of
free space or the 'max' keyword.
")
      (value "max")
      
      (name "partman-lvm/device_remove_lvm")
      (comment "If one of the disks that are going to be automatically partitioned
contains an old LVM configuration, the user will normally receive a
warning. This can be preseeded away...
")
      (value "True")
      
      (name "partman-md/device_remove_md")
      (comment "The same applies to pre-existiing software RAID array:")
      (value "True")
      
      (name "partman-lvm/confirm")
      (comment "And the same goes for the confirmation to write the lvm partitions.")
      (value "True")
      
      (name "partman-lvm/confirm_nooverwrite")
      (value "True")
      
      (name "partman-auto/choose_recipe")
      (comment "You can choose one of the three predefined partitioning recipes:
- atomic: all files in one partition
- home:   separate /home partition
- multi:  separate /home, /var, and /tmp partitions
")
      (type "select")
      (value "multi")
      
      (name "partman-auto/expert_recipe_file")
      (comment "Or provide a recipe of your own...
If you have a way to get a recipe file into the d-i environment, you can
just point at it.
")
      (value "/hd-media/recipe")
      (state "comment")
      
      (name "partman-auto/expert_recipe")
      (comment "If not, you can put an entire recipe into the preconfiguration file in one
(logical) line. This example creates a small /boot partition, suitable
swap, and uses the rest of the space for the root partition:
")
      (value "boot-root ::                                            \\
        40 50 100 ext3                                  \\
                $primary{ } $bootable{ }                \\
                method{ format } format{ }              \\
                use_filesystem{ } filesystem{ ext3 }    \\
                mountpoint{ /boot }                     \\
        .                                               \\
        500 10000 1000000000 ext3                       \\
                method{ format } format{ }              \\
                use_filesystem{ } filesystem{ ext3 }    \\
                mountpoint{ / }                         \\
        .                                               \\
        64 512 300% linux-swap                          \\
                method{ swap } format{ }                \\
        .
")
      (state "comment")
      
      (name "comment_partman_docs")
      (comment "The full recipe format is documented in the file partman-auto-recipe.txt
included in the 'debian-installer' package or available from D-I source
repository. This also documents how to specify settings such as file
system labels, volume group names and which physical devices to include
in a volume group.
")
      (state "hidden")
      
      (name "comment_partman_efi")
      (comment "Partitioning for EFI
If your system needs an EFI partition you could add something like
this to the recipe above, as the first element in the recipe:
              538 538 1075 free                              \\
                     $iflabel{ gpt }                         \\
                     $reusemethod{ }                         \\
                     method{ efi }                           \\
                     format{ }                               \\
              .                                              \\

The fragment above is for the amd64 architecture; the details may be
different on other architectures. The 'partman-auto' package in the
D-I source repository may have an example you can follow.
")
      (state "hidden")
      
      (name "partman-partitioning/confirm_write_new_label")
      (comment "This makes partman automatically partition without confirmation, provided
that you told it what to do using one of the methods above.
")
      (value "True")
      
      (name "partman/choose_partition")
      (type "select")
      (value "finish")
      
      (name "partman/confirm")
      (value "True")
      
      (name "partman/confirm_nooverwrite")
      (value "True")
      
      (name "partman-efi/non_efi_system")
      (comment "Force UEFI booting ('BIOS compatibility' will be lost). Default: false.
")
      (value "True")
      (state "comment")
      
      (name "partman-partitioning/choose_label")
      (comment "Ensure the partition table is GPT - this is required for EFI
")
      (value "gpt")
      (state "comment")
      
      (name "partman-partitioning/default_label")
      (value "gpt")
      (state "comment")
      
      (name "partman-auto-crypto/erase_disks")
      (comment "When disk encryption is enabled, skip wiping the partitions beforehand.
")
      (value "False")
      (state "comment")
      
      (name "raid_partman-auto/method")
      (option "partman-auto/method")
      (comment "Partitioning using RAID
The method should be set to \"raid\".
")
      (value "raid")
      (state "comment")
      
      (name "raid_partman-auto/disk")
      (option "partman-auto/disk")
      (comment "Specify the disks to be partitioned. They will all get the same layout,
so this will only work if the disks are the same size.
")
      (value (list
          "/dev/sda"
          "/dev/sdb"))
      (state "comment")
      
      (name "raid_partman-auto/expert_recipe")
      (option "partman-auto/expert_recipe")
      (comment "Next you need to specify the physical partitions that will be used.
")
      (value "multiraid ::                                         \\
        1000 5000 4000 raid                          \\
                $primary{ } method{ raid }           \\
        .                                            \\
        64 512 300% raid                             \\
                method{ raid }                       \\
        .                                            \\
        500 10000 1000000000 raid                    \\
                method{ raid }                       \\
        .
")
      (state "comment")
      
      (name "partman-auto-raid/recipe")
      (comment "Last you need to specify how the previously defined partitions will be
used in the RAID setup. Remember to use the correct partition numbers
for logical partitions. RAID levels 0, 1, 5, 6 and 10 are supported;
devices are separated using \"#\".
Parameters are:
<raidtype> <devcount> <sparecount> <fstype> <mountpoint> \\
         <devices> <sparedevices>
")
      (value "1 2 0 ext3 /                    \\
      /dev/sda1#/dev/sdb1       \\
.                               \\
1 2 0 swap -                    \\
      /dev/sda5#/dev/sdb5       \\
.                               \\
0 2 0 ext3 /home                \\
      /dev/sda6#/dev/sdb6       \\
.
")
      (state "comment")
      
      (name "comment_partman-raid")
      (comment "For additional information see the file partman-auto-raid-recipe.txt
included in the 'debian-installer' package or available from D-I source
repository.
")
      (state "hidden")
      
      (name "partman-md/confirm")
      (comment "This makes partman automatically partition without confirmation.")
      (value "True")
      (state "comment")
      
      (name "partman/mount_style")
      (comment "Controlling how partitions are mounted
The default is to mount by UUID, but you can also choose \"traditional\" to
use traditional device names, or \"label\" to try filesystem labels before
falling back to UUIDs.
")
      (type "select")
      (value "uuid")
      (state "comment")
      
      (name "base-installer/install-recommends")
      (comment "Base system installation
Configure APT to not install recommended packages by default. Use of this
option can result in an incomplete system and should only be used by very
experienced users.
")
      (value "False")
      (state "comment")
      
      (name "base-installer/kernel/image")
      (comment "The kernel image (meta) package to be installed; \"none\" can be used if no
kernel is to be installed.
")
      (value "linux-image-amd64")
      (state "comment")
      
      (name "apt-setup/non-free")
      (comment "Apt setup
You can choose to install non-free and contrib software.
")
      (value "True")
      (state "comment")
      
      (name "apt-setup/contrib")
      (value "True")
      (state "comment")
      
      (name "apt-setup/use_mirror")
      (comment "Uncomment this if you don't want to use a network mirror.
")
      (value "False")
      (state "comment")
      
      (name "apt-setup/services-select")
      (comment "Select which update services to use; define the mirrors to be used.
Values shown below are the normal defaults.
")
      (type "multiselect")
      (value "security, updates")
      (state "comment")
      
      (name "apt-setup/security_host")
      (value "security.debian.org")
      (state "comment")
      
      (name "apt-setup/local0/repository")
      (comment "Additional repositories, local[0-9] available
")
      (value "http://server.example.org/debian stable main")
      (state "comment")
      
      (name "apt-setup/local0/comment")
      (value "local server")
      (state "comment")
      
      (name "apt-setup/local0/source")
      (comment "Enable deb-src lines")
      (value "True")
      (state "comment")
      
      (name "apt-setup/local0/key")
      (comment "URL to the public key of the local repository; you must provide a key or
apt will complain about the unauthenticated repository and so the
sources.list line will be left commented out.

If the provided key file ends in \".asc\" the key file needs to be an
ASCII-armoured PGP key, if it ends in \".gpg\" it needs to use the
\"GPG key public keyring\" format, the \"keybox database\" format is
currently not supported.
")
      (value "http://server.example.org/key.asc")
      (state "comment")
      
      (name "debian-installer/allow_unauthenticated")
      (comment "By default the installer requires that repositories be authenticated
using a known gpg key. This setting can be used to disable that
authentication. Warning: Insecure, not recommended.
")
      (value "True")
      (state "comment")
      
      (name "apt-setup/multiarch")
      (comment "Uncomment this to add multiarch configuration for i386
")
      (value "i386")
      (state "comment")
      
      (name "tasksel/first")
      (owner "tasksel")
      (comment "Package selection")
      (type "multiselect")
      (value "standard, web-server, kde-desktop")
      (state "comment")
      
      (name "pkgsel/include")
      (comment "Individual additional packages to install")
      (value "openssh-server build-essential")
      (state "comment")
      
      (name "pkgsel/upgrade")
      (comment "Whether to upgrade packages after debootstrap.
Allowed values: none, safe-upgrade, full-upgrade
")
      (type "select")
      (value "none")
      (state "comment")
      
      (name "popularity-contest/participate")
      (owner "popularity-contest")
      (comment "Some versions of the installer can report back on what software you have
installed, and what software you use. The default is not to report back,
but sending reports helps the project determine what software is most
popular and should be included on the first CD/DVD.
")
      (value "False")
      (state "comment")
      
      (name "grub-installer/only_debian")
      (comment "Boot loader installation
Grub is the boot loader (for x86).

This is fairly safe to set, it makes grub install automatically to the UEFI
partition/boot record if no other operating system is detected on the machine.
")
      (value "True")
      
      (name "grub-installer/with_other_os")
      (comment "This one makes grub-installer install to the UEFI partition/boot record, if
it also finds some other OS, which is less safe as it might not be able to
boot that other OS.
")
      (value "True")
      
      (name "grub-installer/bootdev")
      (comment "Due notably to potential USB sticks, the location of the primary drive can
not be determined safely in general, so this needs to be specified:
")
      (value "/dev/sda")
      (state "comment")
      
      (name "grub-installer/bootdev_default")
      (option "grub-installer/bootdev")
      (comment "To install to the primary device (assuming it is not a USB stick):
")
      (value "default")
      (state "comment")
      
      (name "other_grub-installer/only_debian")
      (option "grub-installer/only_debian")
      (comment "Alternatively, if you want to install to a location other than the UEFI
partition/boot record, uncomment and edit these lines:
")
      (value "False")
      (state "comment")
      
      (name "other_grub-installer/with_other_os")
      (option "grub-installer/with_other_os")
      (value "False")
      (state "comment")
      
      (name "other_grub-installer/bootdev")
      (option "grub-installer/bootdev")
      (value "(hd0,1)")
      (state "comment")
      
      (name "multi_grub-installer/bootdev")
      (option "grub-installer/bootdev")
      (comment "To install grub to multiple disks:")
      (value (list
          "(hd0,1)"
          "(hd1,1)"
          "(hd2,1)"))
      (state "comment")
      
      (name "grub-installer/password")
      (comment "Optional password for grub, either in clear text
")
      (type "password")
      (value "r00tme")
      (state "comment")
      
      (name "grub-installer/password-again")
      (type "password")
      (value "r00tme")
      (state "comment")
      
      (name "grub-installer/password-crypted")
      (comment "or encrypted using an MD5 hash, see grub-md5-crypt(8).
")
      (type "password")
      (value "[MD5 hash]")
      (state "comment")
      
      (name "debian-installer/add-kernel-opts")
      (comment "Use the following option to add additional boot parameters for the
installed system (if supported by the bootloader installer).
Note: options passed to the installer will be added automatically.
")
      (value "nousb")
      (state "comment")
      
      (name "finish-install/keep-consoles")
      (comment "Finishing up the installation
During installations from serial console, the regular virtual consoles
(VT1-VT6) are normally disabled in /etc/inittab. Uncomment the next
line to prevent this.
")
      (value "True")
      (state "comment")
      
      (name "finish-install/reboot_in_progress")
      (comment "Avoid that last message about the install being complete.")
      (type "note")
      (value "")
      
      (name "cdrom-detect/eject")
      (comment "This will prevent the installer from ejecting the CD during the reboot,
which is useful in some situations.
")
      (value "False")
      (state "comment")
      
      (name "debian-installer/exit/halt")
      (comment "This is how to make the installer shutdown when finished, but not
reboot into the installed system.
")
      (value "True")
      (state "comment")
      
      (name "debian-installer/exit/poweroff")
      (comment "This will power off the machine instead of just halting it.
")
      (value "True")
      (state "comment")
      
      (name "comment_other_preseeds")
      (comment "Preseeding other packages
Depending on what software you choose to install, or if things go wrong
during the installation process, it's possible that other questions may
be asked. You can preseed those too, of course. To get a list of every
possible question that could be asked during an install, do an
installation, and then run these commands:
  debconf-get-selections --installer > file
  debconf-get-selections >> file
")
      (state "hidden")
      
      (name "comment_advanced_options")
      (comment "Advanced options
Running custom commands during the installation
d-i preseeding is inherently not secure. Nothing in the installer checks
for attempts at buffer overflows or other exploits of the values of a
preconfiguration file like this one. Only use preconfiguration files from
trusted locations! To drive that home, and because it's generally useful,
here's a way to run any shell command you'd like inside the installer,
automatically.
")
      (state "hidden")
      
      (name "preseed/early_command")
      (comment "This first command is run as early as possible, just after
preseeding is read.
")
      (value "anna-install some-udeb")
      (state "comment")
      
      (name "partman/early_command")
      (comment "This command is run immediately before the partitioner starts. It may be
useful to apply dynamic partitioner preseeding that depends on the state
of the disks (which may not be visible when preseed/early_command runs).
")
      (value "debconf-set partman-auto/disk \"$(list-devices disk | head -n1)\"")
      (state "comment")
      
      (name "preseed/late_command")
      (comment "This command is run just before the install finishes, but when there is
still a usable /target directory. You can chroot to /target and use it
directly, or use the apt-install and in-target commands to easily install
packages and run commands in the target system.
")
      (value "apt-install zsh; in-target chsh -s /bin/zsh")
      (state "comment")))
  (preseed__default_configuration (list
      
      (name "debian-installer/locale")
      (value (jinja "{{ ansible_local.locales.system_locale | d(\"en_US.UTF-8\") }}"))
      
      (name "mirror/http/hostname")
      (value "deb.debian.org")
      
      (name "passwd/make-user")
      (value "False")
      (state "present")
      
      (name "passwd/root-password-crypted")
      (value (jinja "{{ preseed__debian_root_password }}"))
      (state "present")
      
      (name "time/zone")
      (value (jinja "{{ ansible_local.tzdata.timezone | d(\"Etc/UTC\") }}"))
      
      (name "clock-setup/ntp-server")
      (value (list
          "0.debian.pool.ntp.org"
          "1.debian.pool.ntp.org"
          "2.debian.pool.ntp.org"
          "3.debian.pool.ntp.org"))
      (state "present")
      
      (name "partman-efi/non_efi_system")
      (state "present")
      
      (name "partman-partitioning/choose_label")
      (state "present")
      
      (name "partman-partitioning/default_label")
      (state "present")
      
      (name "apt-setup/services-select")
      (value "security, updates, backports")
      (state "present")
      
      (name "apt-setup/cdrom/set-first")
      (copy_id_from "apt-setup/multiarch")
      (comment "Do not scan the CD-ROM image for available packages
Ref: https://unix.stackexchange.com/a/409237
")
      (value "False")
      
      (name "apt-setup/cdrom/set-next")
      (copy_id_from "apt-setup/multiarch")
      (value "False")
      
      (name "apt-setup/cdrom/set-failed")
      (copy_id_from "apt-setup/multiarch")
      (value "False")
      
      (name "apt-setup/disable-cdrom-entries")
      (copy_id_from "apt-setup/multiarch")
      (value "True")
      
      (name "tasksel/first")
      (value "ssh-server")
      (state "present")
      
      (name "pkgsel/include")
      (value (jinja "{{ preseed__debian_packages }}"))
      (state "present")
      
      (name "pkgsel/upgrade")
      (value "full-upgrade")
      (state "present")
      
      (name "grub-installer/with_other_os")
      (value "False")
      
      (name "grub-installer/bootdev_default")
      (state "present")
      
      (name "debian-installer/add-kernel-opts")
      (value (jinja "{{ preseed__debian_kernel_arguments }}"))
      (state "present")
      
      (name "cdrom-detect/eject")
      (value "True")
      (state "present")
      
      (name "preseed/late_command")
      (value "in-target curl --output /tmp/postinst.sh http://" (jinja "{{ preseed__base_domain }}") "/${flavor}/d-i/${release}/postinst.sh;\\
in-target chmod +x /tmp/postinst.sh;\\
in-target /tmp/postinst.sh
")
      (state "present")))
  (preseed__configuration (list))
  (preseed__group_configuration (list))
  (preseed__host_configuration (list))
  (preseed__combined_configuration (jinja "{{ preseed__original_configuration
                                     + preseed__default_configuration
                                     + preseed__configuration
                                     + preseed__group_configuration
                                     + preseed__host_configuration }}"))
  (preseed__options_interactive_partman (list
      
      (name "partman-auto/method")
      (state "comment")
      
      (name "partman-auto-lvm/guided_size")
      (state "comment")
      
      (name "partman-lvm/device_remove_lvm")
      (state "comment")
      
      (name "partman-md/device_remove_md")
      (state "comment")
      
      (name "partman-lvm/confirm")
      (state "comment")
      
      (name "partman-lvm/confirm_nooverwrite")
      (state "comment")
      
      (name "partman-auto/choose_recipe")
      (state "comment")
      
      (name "partman-partitioning/confirm_write_new_label")
      (state "comment")
      
      (name "partman/choose_partition")
      (state "comment")
      
      (name "partman/confirm")
      (state "comment")
      
      (name "partman/confirm_nooverwrite")
      (state "comment")))
  (preseed__options_ansible_user (list
      
      (name "passwd/root-login")
      (value "False")
      (state "present")
      
      (name "passwd/make-user")
      (value "True")
      (state "present")
      
      (name "passwd/user-fullname")
      (value (jinja "{{ preseed__admin_fullname }}"))
      (state "present")
      
      (name "passwd/username")
      (value (jinja "{{ preseed__admin_name }}"))
      (state "present")
      
      (name "passwd/user-password-crypted")
      (value (jinja "{{ preseed__debian_admin_password }}"))
      (state "present")
      
      (name "passwd/user-default-groups")
      (value (list
          "adm"
          "staff"))
      (state "present")))
  (preseed__options_enable_nonfree (list
      
      (name "apt-setup/non-free")
      (value "True")
      (state "present")
      
      (name "apt-setup/contrib")
      (value "True")
      (state "present")))
  (preseed__nginx__dependent_servers (list
      
      (by_role "debops.preseed")
      (enabled "True")
      (ssl "False")
      (filename "debops.preseed_http")
      (name (jinja "{{ preseed__domains }}"))
      (root (jinja "{{ preseed__www + \"/$preseed\" }}"))
      (webroot_create "False")
      (location 
        (/ "try_files $uri $uri/ $uri.html /index.html =404;
autoindex on;
types {
        text/plain cfg sh;
}
")
        (~ /d-i/ "index index.html index.htm preseed.cfg ;
try_files $uri $uri/ $uri.html /index.html =404;
autoindex on;
types {
        text/plain cfg sh;
}
"))
      (state "present")
      
      (by_role "debops.preseed")
      (enabled "True")
      (listen "False")
      (filename "debops.preseed_https")
      (name (jinja "{{ preseed__domains }}"))
      (root (jinja "{{ preseed__www + \"/$preseed\" }}"))
      (webroot_create "False")
      (location 
        (/ "try_files $uri $uri/ $uri.html /index.html =404;
autoindex on;
types {
        text/plain cfg sh;
}
")
        (~ /d-i/ "index index.html index.htm preseed.cfg ;
try_files $uri $uri/ $uri.html /index.html =404;
autoindex on;
types {
        text/plain cfg sh;
}
"))
      (state (jinja "{{ \"present\" if (ansible_local.pki.enabled | d()) | bool else \"absent\" }}")))))
