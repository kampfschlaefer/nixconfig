{ config, lib, pkgs, ... }:

{
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget tcpdump nmap
    htop atop psmisc sysstat which
    vimNox byobu tmux python
    gptfdisk parted hdparm
    git gitAndTools.git-crypt
  ];
  environment.shellAliases = {
    vi = "vim";
  };

  programs.bash.enableCompletion = true;
  environment.sessionVariables = {
    EDITOR = "vim";
  };


  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  #services.sudo.wheelNeedsPassword = false;
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.ssh.sshAgentAuth = true;
}