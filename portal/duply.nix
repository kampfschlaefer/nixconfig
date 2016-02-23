{ config, pkgs, ... }:

{
  fileSystems = {
    "/media/duplydisk" = {
      device = "/dev/disk/by-uuid/4bff6ea6-a6f4-4163-9a7e-1703c84cb769";
      options = "noauto";
    };
    "/media/backupdrop" = { device = "/dev/portalgroup/backupdrop"; };
  };
  systemd.automounts = [
    {
      wantedBy = [ "multi-user.target" ];
      where = "/media/duplydisk";
    }
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    ''## rsync from xingu
    command="${pkgs.rrsync}/bin/rrsync /media/backupdrop/xingu-root",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCyDU2ExXgzRGm/eI9viDvh11C1k3RDayVf1oP6DAymnR/GcCpyjkJhzv0+wss1gNR10bHipKCsKht/i796bW/F3YG6xtBPDbtXeTn9zdgyN1vr3sG5pbG1N4VyAXhA6xYyeZK23s+rOfp3OTFcHPwXyF78upC0MbHgLnJu+zrN5sDxd6QAqfYxwf+uE2YQoonhIhxXy8OqaamkpJBHXu0e7R3z/Qy1bKt6Cjfv9Q7Jbr2WMFbfK1YG96sWuFwngc1nqKm24784z3793Rne8pDGjNicRODOptf4b6BvHEF09r+fVIN2oKK+vrzmt+IxRxNwwYGe51SHXeERsawi+t6xhzaNtk1AUf47A5SQPiw7aOS0IoTtxkxZkf7Y0IclQ+S22GDtfR4mBYUQ4BYrxNusi6cILHZWr8BnagrA41xasUhuRapyrPO5hpevyiAlRdLx3QnoWlewNZXBQl2L1gSpCQVNyUocUu0QbZjGSZP9QDY3iYvf0UtkD3gkbef7pHyi3kO9byruaQnCrB9dqySLin+kV2afVqi7T2Jlrj81aXSFoDBInypTHXH9wp+b7Kte2VTCxZeLwTeyJ6GrX2G/ZvvxBXFJujQvTIsSfg8xtaMOe8pqMUFqCuNOgSU/PqOBff79CUv5jRFg2hgQegNQ54SbamQ7yHXTLTyYSI8ykw== root@xingu.arnoldarts.de''
    ''## rsync from starbase
    command="${pkgs.rrsync}/bin/rrsync /media/backupdrop/starbase-root",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCnjx8PXsmkzbozhnnUzGGH2SPsLp8j+KqEqE1K3gmbHdYWfqF18hD1HaZRG/ghBOlQChMeKZ3oMRZxzh2BkczW260YhJBCJbp9Jx2Qq2IICoyg/0xeI3cv2BZeeENq993r80kRl7X61W8BsUxFn0sHBkZOr+SETlpRw+ApS96kx8JPDO7LDMwB1yxSSxjKRzoxMsXoGQsTypsxha6SP0y4uK4dQPY3ntN0hPbXoJcxXVG3wjoilt/zR24+lg3Uu07tIn6pirFEE1zyb145pHtyrrWeYjj0wHc5aDMQtw2I5aBrQ3YtJEE/xIRv6vHG7DuTVv/Qny8RfbGFCqjrw0Gh root@starbase''
  ];

  systemd.services.duplyportal = {
    path = [ pkgs.bash pkgs.duply pkgs.duplicity ];
    serviceConfig = {
      User = "root";
      WorkingDirectory = "/root";
    };
    environment =  {
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
    script = "duply portaldisk backup";
    startAt = "*-*-* 3:10:00";
  };
  systemd.services.duplyportal-purge = {
    path = [ pkgs.bash pkgs.duply pkgs.duplicity ];
    serviceConfig = {
      User = "root";
      WorkingDirectory = "/root";
    };
    environment =  {
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
    script = "duply portaldisk purge --force && duply portaldisk purgeFull --force";
    startAt = "monthly";
  };


  systemd.services.duplyamazon = {
    path = [ pkgs.bash pkgs.duply pkgs.duplicity ];
    serviceConfig = {
      User = "root";
      WorkingDirectory = "/root";
    };
    environment =  {
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
    script = "duply amazon backup";
    startAt = "*-*-1/3 2:10:00";
  };
}
