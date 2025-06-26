{
  config,
  lib,
  ...
}: {
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    echo "Rollback running" > /mnt/rollback.log
     mkdir -p /mnt
     mount -t btrfs /dev/mapper/cryptroot /mnt

     # Recursively delete all nested subvolumes inside /mnt/root
     btrfs subvolume list -o /mnt/root | cut -f9 -d' ' | while read subvolume; do
       echo "Deleting /$subvolume subvolume..." >> /mnt/rollback.log
       btrfs subvolume delete "/mnt/$subvolume"
     done

     echo "Deleting /root subvolume..." >> /mnt/rollback.log
     btrfs subvolume delete /mnt/root

     echo "Restoring blank /root subvolume..." >> /mnt/rollback.log
     btrfs subvolume snapshot /mnt/root-blank /mnt/root

     umount /mnt
  '';

  environment.persistence."/persist" = {
    directories = [
      "/etc"
      "/var/spool"
      "/root"
      "/srv"
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
    ];
    files = [
      # "/etc/machine-id"
      # Add more files you want to persist
    ];
  };

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';
}
