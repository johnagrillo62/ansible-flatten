(playbook "debops/ansible/roles/minidlna/defaults/main.yml"
  (minidlna__base_packages (list
      "minidlna"))
  (minidlna__packages (list))
  (minidlna__allow (list))
  (minidlna__group_allow (list))
  (minidlna__host_allow (list))
  (minidlna__ssdp_allow (list))
  (minidlna__ssdp_group_allow (list))
  (minidlna__ssdp_host_allow (list))
  (minidlna__original_configuration (list
      
      (name "user")
      (comment "Specify the user name or uid to run as (root by default).
On Debian system command line option (from /etc/default/minidlna) overrides this.
")
      (value "minidlna")
      (state "comment")
      
      (name "media_dir")
      (comment "Path to the directory you want scanned for media files.

This option can be specified more than once if you want multiple directories
scanned.

If you want to restrict a media_dir to a specific content type, you can
prepend the directory name with a letter representing the type (A, P or V),
followed by a comma, as so:
  * \"A\" for audio    (eg. media_dir=A,/var/lib/minidlna/music)
  * \"P\" for pictures (eg. media_dir=P,/var/lib/minidlna/pictures)
  * \"V\" for video    (eg. media_dir=V,/var/lib/minidlna/videos)
  * \"PV\" for pictures and video (eg. media_dir=PV,/var/lib/minidlna/digital_camera)
")
      (value (list
          "/var/lib/minidlna"))
      
      (name "merge_media_dirs")
      (comment "Set this to merge all media_dir base contents into the root container
(The default is no.)
")
      (value "False")
      (state "comment")
      
      (name "db_dir")
      (comment "Path to the directory that should hold the database and album art cache.")
      (value "/var/cache/minidlna")
      (state "comment")
      
      (name "log_dir")
      (comment "Path to the directory that should hold the log file.")
      (value "/var/log/minidlna")
      (state "comment")
      
      (name "log_level")
      (comment "Type and minimum level of importance of messages to be logged.

The types are \"artwork\", \"database\", \"general\", \"http\", \"inotify\",
\"metadata\", \"scanner\", \"ssdp\" and \"tivo\".

The levels are \"off\", \"fatal\", \"error\", \"warn\", \"info\" or \"debug\".
\"off\" turns of logging entirely, \"fatal\" is the highest level of importance
and \"debug\" the lowest.

The types are comma-separated, followed by an equal sign (\"=\"), followed by a
level that applies to the preceding types. This can be repeated, separating
each of these constructs with a comma.

The default is to log all types of messages at the \"warn\" level.
")
      (value "general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=warn")
      (state "comment")
      
      (name "root_container")
      (comment "Use a different container as the root of the directory tree presented to
clients. The possible values are:
  * \".\" - standard container
  * \"B\" - \"Browse Directory\"
  * \"M\" - \"Music\"
  * \"P\" - \"Pictures\"
  * \"V\" - \"Video\"
  * Or, you can specify the ObjectID of your desired root container
    (eg. 1$F for Music/Playlists)
If you specify \"B\" and the client device is audio-only then \"Music/Folders\"
will be used as root.
")
      (value ".")
      (state "comment")
      
      (name "network_interface")
      (comment "Network interface(s) to bind to (e.g. eth0), comma delimited.
This option can be specified more than once.
")
      (value (list))
      (state "comment")
      
      (name "port")
      (comment "Port number for HTTP traffic (descriptions, SOAP, media transfer).
This option is mandatory (or it must be specified on the command-line using
\"-p\").
")
      (value "8200")
      
      (name "presentation_url")
      (comment "URL presented to clients (e.g. http://example.com:80).
")
      (value "/")
      (state "comment")
      
      (name "friendly_name")
      (comment "Name that the DLNA server presents to clients.
Defaults to \"hostname: username\".
")
      (value "")
      (state "comment")
      
      (name "serial")
      (comment "Serial number the server reports to clients.
Defaults to the MAC address of network interface.
")
      (value "")
      (state "comment")
      
      (name "uuid")
      (comment "Specify device's UPnP UUID minidlna should use. By default MAC address is
used to build uniq UUID.
")
      (value "")
      (state "comment")
      
      (name "model_name")
      (comment "Model name the server reports to clients.")
      (value "Windows Media Connect compatible (MiniDLNA)")
      (state "comment")
      
      (name "model_number")
      (comment "Model number the server reports to clients.
Defaults to the version number of minidlna.
")
      (value "")
      (state "comment")
      
      (name "inotify")
      (comment "Automatic discovery of new files in the media_dir directory.")
      (value "True")
      (state "comment")
      
      (name "album_art_names")
      (comment "List of file names to look for when searching for album art.
Names should be delimited with a forward slash (\"/\").
This option can be specified more than once.
")
      (value (list
          "Cover.jpg/cover.jpg/AlbumArtSmall.jpg/albumartsmall.jpg"
          "AlbumArt.jpg/albumart.jpg/Album.jpg/album.jpg"
          "Folder.jpg/folder.jpg/Thumb.jpg/thumb.jpg"))
      
      (name "strict_dlna")
      (comment "Strictly adhere to DLNA standards.
This allows server-side downscaling of very large JPEG images, which may
decrease JPEG serving performance on (at least) Sony DLNA products.
")
      (value "False")
      (state "comment")
      
      (name "enable_tivo")
      (comment "Support for streaming .jpg and .mp3 files to a TiVo supporting HMO.")
      (value "False")
      (state "comment")
      
      (name "tivo_discovery")
      (comment "Which method to use for registering in TiVo: 'bonjour' (default) or
legacy 'beacon'
")
      (value "bonjour")
      (state "comment")
      
      (name "notify_interval")
      (comment "SSDP notify interval, in seconds.")
      (value "895")
      (state "comment")
      
      (name "minissdpdsocket")
      (comment "Path to the MiniSSDPd socket, for MiniSSDPd support.")
      (value "/run/minissdpd.sock")
      (state "comment")
      
      (name "force_sort_criteria")
      (comment "Always set SortCriteria to this value, regardless of the SortCriteria
passed by the client
e.g. force_sort_criteria=+upnp:class,+upnp:originalTrackNumber,+dc:title
")
      (value "")
      (state "comment")
      
      (name "max_connections")
      (comment "maximum number of simultaneous connections
note: many clients open several simultaneous connections while streaming
")
      (value "50")
      (state "comment")
      
      (name "wide_links")
      (comment "set this to yes to allow symlinks that point outside user-defined media_dirs.")
      (value "False")
      (state "comment")))
  (minidlna__default_configuration (list
      
      (name "notify_interval")
      (value "30")
      (state "present")))
  (minidlna__configuration (list))
  (minidlna__group_configuration (list))
  (minidlna__host_configuration (list))
  (minidlna__combined_configuration (jinja "{{ minidlna__original_configuration
                                      + minidlna__default_configuration
                                      + minidlna__configuration
                                      + minidlna__group_configuration
                                      + minidlna__host_configuration }}"))
  (minidlna__ferm__dependent_rules (list
      
      (name "minidlna_allow_http")
      (type "accept")
      (dport (list
          "minidlna"))
      (protocol (list
          "tcp"))
      (saddr (jinja "{{ minidlna__allow + minidlna__group_allow + minidlna__host_allow }}"))
      (weight "50")
      (by_role "debops.minidlna")
      
      (name "minidlna_allow_ssdp")
      (type "accept")
      (dport (list
          "ssdp"))
      (protocol (list
          "udp"))
      (saddr (jinja "{{ minidlna__ssdp_allow + minidlna__ssdp_group_allow + minidlna__ssdp_host_allow }}"))
      (accept_any "False")
      (weight "50")
      (by_role "debops.minidlna")))
  (minidlna_server__etc_services__dependent_list (list
      
      (name "ssdp")
      (port "1900")
      (protocol (list
          "udp"))
      (comment "Simple Service Discovery Protocol")
      
      (name "minidlna")
      (port "8200")
      (protocol (list
          "tcp"))
      (comment "MiniDLNA media server Web Interface"))))
