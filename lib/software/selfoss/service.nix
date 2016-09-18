{ config, lib, pkgs, ...}:

with lib;

let
  selfossinstance = {
    dbtype = mkOption {
      type = types.str;
      default = "sqlite";
    };
  };

  selfosspkg = pkgs.callPackage ./default.nix {};

  selfossinstpkg = instancename: instance: let
    targets = [ "index.php" "common.php" "controllers" "daos" "defaults.ini" "helpers" "libs" "spouts" "templates" ];
  in pkgs.stdenv.mkDerivation rec {
    name = "selfoss-${instancename}";

    src = ./.;
    buildInputs = [ selfosspkg ];

    dontBuild = true;

    installPhase = ''
      mkdir $out

      ${concatMapStrings (target: ''
        ln -s ${selfosspkg}/${target} $out/${target};
      '') targets}

      ln -s /var/lib/selfoss/${instancename}/data $out/data
      ln -s /var/lib/selfoss/${instancename}/public $out/public
    '';
  };

  cfg = config.services.selfoss;


  hasInstances = length(attrNames cfg) > 0;

  nginxcfg = config.services.nginx;

  #instances = mapAttrsToList selfossinstpkg cfg;

  selfossprestarts = concatStringsSep "\n" (
    mapAttrsToList (name: opts: ''
      if [ ! -d /var/lib/selfoss/${name} ]; then
        mkdir -p /var/lib/selfoss/${name}
        cp -R ${selfosspkg}/data /var/lib/selfoss/${name}
        cp -R ${selfosspkg}/public /var/lib/selfoss/${name}
      fi
      chown -R ${nginxcfg.user}:${nginxcfg.group} /var/lib/selfoss/${name}
    '') cfg
  );

  httpconfig = concatStringsSep "\n" (
    mapAttrsToList (name: opts:
      let
        instance = selfossinstpkg name opts;
      in ''
      server {
        server_name ${name};

        root ${instance};

        index index.php;

        location ~ \.php$ {
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          fastcgi_pass unix:/run/phpfpm/selfoss;
          fastcgi_index index.php;
          fastcgi_param SCRIPT_FILENAME ${instance}/$fastcgi_script_name;
          fastcgi_param SCRIPT_NAME     $fastcgi_script_name;
          fastcgi_param DOCUMENT_ROOT   $document_root;
          fastcgi_param QUERY_STRING    $query_string;
          fastcgi_param REQUEST_METHOD  $request_method;
          fastcgi_param CONTENT_TYPE    $content_type;
          fastcgi_param CONTENT_LENGTH  $content_length;
          fastcgi_param REQUEST_URI     $request_uri;
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
      #phpPackage = pkgs.php56;
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
        disable_symlinks off;
        ${httpconfig}
      '';
    };

    systemd.services.nginx.preStart = selfossprestarts;

    environment.systemPackages = [ selfosspkg ];
  };
}