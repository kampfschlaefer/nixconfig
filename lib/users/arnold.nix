{ config, lib, pkgs, ... }:

{

  users.users.arnold = {
    isNormalUser = true;
    uid = 1000;
    group = lib.mkOverride 100 "users";
    extraGroups = [ "wheel" ];
    initialHashedPassword = lib.mkOverride 100 "$6$iGIV7lSJNXd63m$p9ajhxdkbGI8ttLw7Zb3ej/yDjzPuHGAvy5dxUCk8pg4Zh8wGD.Lt4K5gQ/CEdwtvN.ai.z974T9BhVZTapq6.";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRl2ySjWm53HKTmKU02I1M6y5tx0mJMlyBrp/1n4VBeye9wGmSxP+pIwdD1HH9xZC9OPDHv5DPMSlliccbqrq7pIibMXuIg9V+MdzAtzbeMptKvsx/uSUJFGSWwc4W3/QeYpFOp+u5CaQ9ZoMhiwIeVY7Z1UTd8SRRyzMNtsIdF0A61r1AhNoV4CNK8wuKzfAokBEmxUeW+uGuILZeEX6B1y3ml4dWBBSOfYqbEfxU1/mDw5OAMaSo8k3o6CKQ8YVywimeURgnGG0DbVvF6oSNc2xxUKG5EIKc1E5dsaLWR0EwZ9zpvGPWHB1pv0zPBV6gkFwSbP3LpqwTkj8U8YChPw9hrq+ONGEaWVaczLqApw7aUdALpis7nkPueTQdsXD036MuwH6tZWNGEnkZb/JoE9eewPMBJNYnxY9e+Nj9DVitByrKLWA+T4bZEQf4uUl8LEKv4tp8ePYDKiDmRkRLE7CdpkO5f2vttMrGPMCB0LHvsepy/S6sROSAGzq8VS+fjubRKy6XBHlVrJGQ5eqk7c01H+oDPYSStADXO60fr4YHBBfrQMzc/7/Xb+UrsjJXP5etaNU1H2KPj7SuoEmBhkWrm0KKKdgBYZyl5Cjj5FcAd/hIpreyNDyb6jSgWduXLxc63HZB5aak4N2fDrORd3C8duNN7dswnBjD7MZ4zQ== arnold@xingu.arnoldarts.de"
    ];
  };

}