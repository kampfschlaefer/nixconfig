{ config, lib, pkgs, ... }:

let
  adminkey = if (config.testdata == true) then
    builtins.readFile(./../../lib/tests/data/admin_key.pub)
  else "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRl2ySjWm53HKTmKU02I1M6y5tx0mJMlyBrp/1n4VBeye9wGmSxP+pIwdD1HH9xZC9OPDHv5DPMSlliccbqrq7pIibMXuIg9V+MdzAtzbeMptKvsx/uSUJFGSWwc4W3/QeYpFOp+u5CaQ9ZoMhiwIeVY7Z1UTd8SRRyzMNtsIdF0A61r1AhNoV4CNK8wuKzfAokBEmxUeW+uGuILZeEX6B1y3ml4dWBBSOfYqbEfxU1/mDw5OAMaSo8k3o6CKQ8YVywimeURgnGG0DbVvF6oSNc2xxUKG5EIKc1E5dsaLWR0EwZ9zpvGPWHB1pv0zPBV6gkFwSbP3LpqwTkj8U8YChPw9hrq+ONGEaWVaczLqApw7aUdALpis7nkPueTQdsXD036MuwH6tZWNGEnkZb/JoE9eewPMBJNYnxY9e+Nj9DVitByrKLWA+T4bZEQf4uUl8LEKv4tp8ePYDKiDmRkRLE7CdpkO5f2vttMrGPMCB0LHvsepy/S6sROSAGzq8VS+fjubRKy6XBHlVrJGQ5eqk7c01H+oDPYSStADXO60fr4YHBBfrQMzc/7/Xb+UrsjJXP5etaNU1H2KPj7SuoEmBhkWrm0KKKdgBYZyl5Cjj5FcAd/hIpreyNDyb6jSgWduXLxc63HZB5aak4N2fDrORd3C8duNN7dswnBjD7MZ4zQ== arnold@xingu.arnoldarts.de";
in
{
  fileSystems = {
    "/var/lib/containers/gitolite/var/lib/gitolite" = {
      device = "/dev/portalgroup/gitrepos";
    };
  };

  containers.gitolite = {
    autoStart = lib.mkOverride 100 true;
    privateNetwork = true;
    hostBridge = "lan";

    config = { config, pkgs, ... }: {
      networking = {
        domain = "arnoldarts.de";
        interfaces.eth0 = {
          useDHCP = false;
          ip4 = [{ address = "192.168.1.223"; prefixLength = 24; }];
          ip6 = [{ address = "2001:470:1f0b:1033::67:6974"; prefixLength = 64; }];
        };
        firewall.enable = false;
      };

      services.openssh = {
        enable = true;
        passwordAuthentication = false;
        challengeResponseAuthentication = false;
      };

      services.gitolite = {
        enable = true;
        adminPubkey = adminkey;
      };

      /*services.lighttpd = {
        enable = true;
        gitweb = {
          enable = true;
          projectroot = config.services.gitolite.dataDir + "/repositories";
        };
      };*/

      services.gitDaemon = {
        enable = true;
        basePath = config.services.gitolite.dataDir + "/repositories";
      };

      users.extraUsers.lighttpd.extraGroups = [ config.services.gitDaemon.group ];
      users.extraUsers.gitolite.group = config.services.gitDaemon.group;

      # Make gitolite and lighttpd and gitweb play toghether
      systemd.services."gitolite-init".preStart = ''
        chmod g+rx /var/lib/gitolite
      '';
      systemd.services."gitolite-init".postStart = "
        gitolite print-default-rc > ~/.gitolite.rc
        sed -e 's/UMASK                           =>  0077,/UMASK => 0027,/' -i ~/.gitolite.rc
        sed -e \"s/GIT_CONFIG_KEYS                 =>  '',/GIT_CONFIG_KEYS => '.*',/\" -i ~/.gitolite.rc

        chmod g+rx /var/lib/gitolite/repositories
      ";
      systemd.services."git-daemon".preStart = "[ -d ${config.services.gitolite.dataDir}/repositories ] || sleep 2";
      systemd.services."git-daemon".requires = [ "gitolite-init.service" ];
    };
  };
}
