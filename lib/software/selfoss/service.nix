{ config, lib, pkgs, ...}:

with lib;

let
  selfossinstance = {
    dbtype = mkOption {
      type = types.str;
      default = "sqlite";
    };
    dbhost = mkOption {
      type = types.str;
      default = "localhost";
    };
    dbport = mkOption {
      type = types.int;
    };
    dbname = mkOption {
      type = types.str;
      default = "selfoss";
    };
    dbusername = mkOption {
      type = types.str;
      default = "selfoss";
    };
    dbpassword = mkOption {
      type = types.str;
    };

    servername = mkOption {
      type = types.str;
    };
  };

  selfosspkg = pkgs.callPackage ./default.nix {};

  cfg = config.services.selfoss;

  hasInstances = length(attrNames cfg) > 0;

  nginxcfg = config.services.nginx;

  instanceconfig = opts: ''
    [globals]
    db_type=${opts.dbtype}
    ${lib.optionalString (opts.dbtype == "postgres")
    ''db_host=${opts.dbhost}
      db_database=${opts.dbname}
      db_username=${opts.dbusername}
      db_password=${opts.dbpassword}
      db_port=${opts.dbport}
    ''}
    ${lib.optionalString (opts.dbtype == "sqlite")
    ''db_file=data/sqlite/selfoss.db
    ''}
  '';

  selfossprestarts = concatStringsSep "\n" (
    mapAttrsToList (name: opts: ''
      if [ ! -d /var/lib/selfoss/${name} ]; then
        mkdir -p /var/lib/selfoss/${name}
        cp -R ${selfosspkg}/data /var/lib/selfoss/${name}
        chmod u+w -R /var/lib/selfoss/${name}/data
        cp -R ${selfosspkg}/public /var/lib/selfoss/${name}
        chmod u+w /var/lib/selfoss/${name}/public
      fi
      cd /var/lib/selfoss/${name}
      rm -f config.ini
      echo "${instanceconfig opts}" > config.ini
      for f in index.php common.php controllers daos defaults.ini helpers libs spouts templates; do
        ${pkgs.rsync}/bin/rsync -r --delete ${selfosspkg}/$f ./
      done
      chown -R ${nginxcfg.user}:${nginxcfg.group} .
    '') cfg
  );

  httpconfig = concatStringsSep "\n" (
    mapAttrsToList (name: opts: ''
      server {
        server_name ${opts.servername};

        root /var/lib/selfoss/${name};

        index index.php;

        location ~ \.php$ {
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          fastcgi_pass unix:/run/phpfpm/selfoss;
          fastcgi_index index.php;
          fastcgi_param SCRIPT_FILENAME /var/lib/selfoss/${name}/$fastcgi_script_name;
          fastcgi_param SCRIPT_NAME     $fastcgi_script_name;
          fastcgi_param DOCUMENT_ROOT   $document_root;
          fastcgi_param QUERY_STRING    $query_string;
          fastcgi_param REQUEST_METHOD  $request_method;
          fastcgi_param CONTENT_TYPE    $content_type;
          fastcgi_param CONTENT_LENGTH  $content_length;
          fastcgi_param REQUEST_URI     $request_uri;
          fastcgi_param SERVER_PORT     $server_port;
        }

        access_log syslog:server=unix:/dev/log;
        error_log syslog:server=unix:/dev/log;
      }
    '') cfg
  );

in
{
  options = {
    services.selfoss = mkOption {
      type = types.attrsOf types.optionSet;
      options = selfossinstance;
      default = {};
      description = ''
        named list of selfoss instances.
      '';
    };
  };
  config = mkIf hasInstances {

    services.phpfpm = {
      phpPackage = pkgs.php56;
      extraConfig = ''
        error_log = syslog
        log_level = notice
      '';
      poolConfigs = {
        selfoss = ''
        listen = /run/phpfpm/selfoss
        listen.owner = ${nginxcfg.user}
        user = ${nginxcfg.user}
        group = ${nginxcfg.group}
        pm = dynamic
        pm.max_children = 10
        pm.start_servers = 2
        pm.min_spare_servers = 1
        pm.max_spare_servers = 10
        pm.max_requests = 500
        '';
      };
    };
    services.nginx = {
      enable = true;
      httpConfig = ''
        #disable_symlinks off;
        ${httpconfig}
      '';
    };

    systemd.services.nginx.preStart = selfossprestarts;

    environment.systemPackages = [ selfosspkg ];
  };
}