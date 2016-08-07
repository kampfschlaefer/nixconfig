{ config, lib, pkgs, ... }:

{
  nix.nixPath = [
    "/etc/nixos/nixconfig/nixpkgs"
    "nixpkgs=/etc/nixos/nixconfig/nixpkgs"
    "nixos-config=/etc/nixos/configuration.nix"
  ];

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # users.mutableUsers = false;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget tcpdump nmap
    htop atop psmisc sysstat which
    lshw usbutils dmidecode
    vimNox byobu tmux python
    gptfdisk parted hdparm
    git gitAndTools.git-crypt
  ];
  environment.shellAliases = {
    vi = "vim";
  };

  programs.bash = {
    enableCompletion = true;
    shellInit = ''
      export GIT_PS1_SHOWDIRTYSTATE=true
      export GIT_PS1_SHOWUPSTREAM=true
    '';
    promptInit = ''
      # Provide a nice prompt if the terminal supports it.
        if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
          PROMPT_COLOR="1;31m"
          let $UID && PROMPT_COLOR="1;32m"
          PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\w]\[\033[0m\]$(__git_ps1 )\\$ "
          if test "$TERM" = "xterm"; then
            PS1="\[\033]2;\h:\u:\w\007\]$PS1"
          fi
        fi
    '';
  };
  environment.sessionVariables = {
    EDITOR = "vim";
  };


  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  #services.sudo.wheelNeedsPassword = false;
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.ssh.sshAgentAuth = true;
}