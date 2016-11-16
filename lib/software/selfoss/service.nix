{ config, lib, pkgs, ...}:

with lib;

let
  selfossinstance = {
    dbtype = mkOption {
      type = types.enum [ "sqlite" "pgsql" "mysql" ];
      default = "sqlite";
      description = ''
        The database to use. "sqlite" is the easiest and also the default.
      '';
    };
    dbhost = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The host of the database to connect to.
        Only for database types pgsql and mysql.
      '';
    };
    dbport = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = ''
        Port of the database to connect to for pgsql and mysql.
        Defaults to 5432 for pgsql and 3306 for mysql.
      '';
    };
    dbname = mkOption {
      type = types.str;
      default = "selfoss";
      description = ''
        Name of the database to use.
      '';
    };
    dbusername = mkOption {
      type = types.str;
      default = "selfoss";
      description = ''
        Name of the database user.
      '';
    };
    dbpassword = mkOption {
      type = types.str;
      default = "";
      description = ''
        Password to connect to the database.
      '';
    };

    servername = mkOption {
      type = types.str;
      description = ''
        Name of the nginx-server where the selfoss instance is reachable.
      '';
    };
  };

  selfosspkg = pkgs.callPackage ./default.nix {};

  cfg = config.services.selfoss;

  hasInstances = length(attrNames cfg.instances) > 0;

  nginxcfg = config.services.nginx;

  phppkg = pkgs.php56;

  portForDbtype = dbtype:
    if dbtype == "pgsql"
    then 5432
    else (
      if dbtype == "mysql"
      then 3306
      else null
    );

  instanceconfig = opts: ''
    [globals]
    db_type=${opts.dbtype}
    ${lib.optionalString (opts.dbtype == "pgsql" || opts.dbtype == "mysql")
    ''
      db_host=${opts.dbhost}
      db_database=${opts.dbname}
      db_username=${opts.dbusername}
      db_password=${opts.dbpassword}
      db_port=${toString (if opts.dbport != null then opts.dbport else portForDbtype opts.dbtype)}
    ''}
    ${lib.optionalString (opts.dbtype == "sqlite")
    ''db_file=data/sqlite/selfoss.db
    ''}
    allow_public_update_access=1
    base_url=http://${opts.servername}
    items_lifetime=3000
    homepage=unread
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
      for f in index.php cliupdate.php common.php controllers daos defaults.ini helpers libs spouts templates; do
        ${pkgs.rsync}/bin/rsync -r --delete ${selfosspkg}/$f ./
      done
      chown -R ${nginxcfg.user}:${nginxcfg.group} .
    '') cfg.instances
  );

  httpconfig = concatStringsSep "\n" (
    mapAttrsToList (name: opts: ''
      server {
        server_name ${opts.servername};

        root /var/lib/selfoss/${name};

        index index.php;

        location ~* \ (gif|jpg|png) {
          expires 30d;
        }
        location ~ ^/favicons/.*$ {
          try_files $uri /var/lib/selfoss/${name}/data/$uri;
        }
        location ~ ^/thumbnails/.*$ {
          try_files $uri /var/lib/selfoss/${name}/data/$uri;
        }
        location ~* ^/(data\/logs|data\/sqlite|config\.ini|\.ht) {
          deny all;
        }
        location / {
          index index.php index.html index.htm;
          try_files $uri /public/$uri /index.php$is_args$args;
        }
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
    '') cfg.instances
  );

  updateservice = cfg: {
    path = [ phppkg ];
    serviceConfig = {
      User = nginxcfg.user;
      WorkingDirectory = "/var/lib/selfoss/";
    };
    environment =  {
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
    script = concatMapStrings (
      name: ''
        ( cd ${name} && php -f cliupdate.php )
      ''
    ) (builtins.attrNames cfg.instances);
    startAt = cfg.updateinterval;
  };

in
{
  options = {
    services.selfoss.updateinterval = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Update the feeds with a systemd.timer job in onCalender notation.

        Use "hourly" to get make selfoss fetch the sources each hour.

        'null' disables automatic feed updates completely.
      '';
    };

    services.selfoss.instances = mkOption {
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
      phpPackage = phppkg;
      phpIni = builtins.toFile "php-selfoss.ini" ''
        always_populate_raw_post_data = -1;
        ${readFile "${phppkg}/etc/php-recommended.ini"}
      '';
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

    systemd.services.selfoss_update = mkIf (cfg.updateinterval != null) (updateservice cfg);

    environment.systemPackages = [ selfosspkg ];
  };
}