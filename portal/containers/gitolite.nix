{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/var/lib/containers/gitolite/var/lib/gitolite" = {
      device = "/dev/portalgroup/gitrepos";
    };
  };

  containers.gitolite = {
    autoStart = true;
    privateNetwork = true;
    localAddress = "192.168.10.2";
    hostAddress = "192.168.10.1";
    config = { config, pkgs, ... }: {
      networking.domain = "lan.arnoldarts.de";
      networking.firewall.enable = false;
      services.openssh.enable = true;
      services.gitolite = {
        enable = true;
        adminPubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRl2ySjWm53HKTmKU02I1M6y5tx0mJMlyBrp/1n4VBeye9wGmSxP+pIwdD1HH9xZC9OPDHv5DPMSlliccbqrq7pIibMXuIg9V+MdzAtzbeMptKvsx/uSUJFGSWwc4W3/QeYpFOp+u5CaQ9ZoMhiwIeVY7Z1UTd8SRRyzMNtsIdF0A61r1AhNoV4CNK8wuKzfAokBEmxUeW+uGuILZeEX6B1y3ml4dWBBSOfYqbEfxU1/mDw5OAMaSo8k3o6CKQ8YVywimeURgnGG0DbVvF6oSNc2xxUKG5EIKc1E5dsaLWR0EwZ9zpvGPWHB1pv0zPBV6gkFwSbP3LpqwTkj8U8YChPw9hrq+ONGEaWVaczLqApw7aUdALpis7nkPueTQdsXD036MuwH6tZWNGEnkZb/JoE9eewPMBJNYnxY9e+Nj9DVitByrKLWA+T4bZEQf4uUl8LEKv4tp8ePYDKiDmRkRLE7CdpkO5f2vttMrGPMCB0LHvsepy/S6sROSAGzq8VS+fjubRKy6XBHlVrJGQ5eqk7c01H+oDPYSStADXO60fr4YHBBfrQMzc/7/Xb+UrsjJXP5etaNU1H2KPj7SuoEmBhkWrm0KKKdgBYZyl5Cjj5FcAd/hIpreyNDyb6jSgWduXLxc63HZB5aak4N2fDrORd3C8duNN7dswnBjD7MZ4zQ== arnold@xingu.arnoldarts.de";
      };
      #networking.interfaces.eth0 = {
      #  useDHCP = false;
      #  ip6 = [{ address = "2001:470:1f0b:1033:73:6561:6669:6c65"; prefixLength = 64; }];
      #};
    };
  };
}
