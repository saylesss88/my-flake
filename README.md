- Choose an install method from the following
  [README](https://saylesss88.github.io/installation/index.html)

- This is a starter repo attempting to save you some time and effort. It is used
  for both encrypted and unencrypted setups so pay attention to paths etc.

- If you run into any problems or run into problems open an issue and I'll try
  to get to it ASAP.

> ❗ There are 2 `disk-config`'s, the `disk-config.nix` is for an unencrypted
> setup and `disk-config2.nix` is for encryption. Carefully review what's there
> to ensure you've chosen the correct one. If you choose `disk-config2.nix`,
> uncomment the `boot.initrd` setting in the included `configuration.nix`.

Then set an environment variable for the experimental-features, this enables you
to use `nix-shell -p` to add packages:

```bash
export NIX_CONFIG='experimental-features = nix-command flakes'
```

Add `git` and an editor of your choice and optionally `yazi`:

```bash
nix-shell -p git helix yazi
# This makes yazi open helix when opening a file instead of nano
export EDITOR='hx'
git config --global user.name "YourUsername"
git config --global user.email "YourGitEmail"
```

After you've set up `git` clone the repo:

```bash
git clone https://github.com/saylesss88/my-flake.git
```

1. After cloning this repo, change the `flake.nix`, `users.nix`, and
   `configuration.nix` to your wanted hostname and user.

2. Run `lsblk` and make sure the device is correct in `disk-config.nix`. Change
   it accordingly.

- There have been some recent changes to this repo, giving the option of an
  unencrypted setup with `disk-config.nix` and for an encrypted disk setup with
  `disk-config2.nix`. The process is mainly the same, just with the added step
  of asking for your encryption passphrase when you format the disk with disko.

- Click here for
  [Unencrypted Impermanence](https://saylesss88.github.io/nix/impermanence.html)

- Click here for
  [Encrypted Impermanence](https://saylesss88.github.io/nix/encrypted_impermanence.html)

> ❗ Note: Impermanence is destructive by nature, it is very easy to mess up a
> single thing and break your system and have to start completely over. Be
> careful!

3. `initialHashedPassword`: Run `mkpasswd -m SHA-512 -s > /tmp/pass.txt`, then
   enter your desired password. Use a unique password here as they are
   susceptible to brute force attacks. Example output:

- Open the `users.nix` or wherever you need the hashed password and move your
  cursor to the line where you need it and type `:r /tmp/pass.txt` to read it
  into your current file.

4. Run the disko command:

> ❗ WARNING: This will wipe your whole disk! Disko doesn't work with dual boot.
> Also, ensure that you choose the correct `disk-config.nix` or
> `disk-config2.nix`. This is very important!

```bash
# the following command is for an unencrypted disk
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ~/my-flake/disk-config.nix
# OR the following for encryption
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ~/my-flake/disk-config2.nix
```

5. Check the output of `mount | grep /mnt` you should see the subvolumes listed.

6. Generate your configurations:

```bash
sudo nixos-generate-config --no-filesystems --root /mnt
```

- Disko handles the `fileSystems` attribute for us. It's still important to
  generate your own `hardware-configuration.nix` and replace the one that comes
  with the repo.

7. Add your `networking.hostName`, `git`, `vim`, whatever else you want to your
   `configuration.nix` and run `sudo nixos-rebuild switch` to apply them.

8. Replace `my-flake`'s `hardware-configuration.nix` with the
   `/mnt/etc/nixos/hardware-configuration.nix` that you just generated.

```bash
rm ~/my-flake/hardware-configuration.nix
sudo mv /mnt/etc/nixos/hardware-configuration.nix ~/my-flake
```

9. Move the flake to `/mnt/etc/nixos/`:

```bash
sudo mv ~/my-flake /mnt/etc/nixos/
```

10. Install NixOS replace #hostname with your hostname:

```bash
sudo nixos-install --flake /mnt/etc/nixos/my-flake#hostname
# or
sudo nixos-install --flake /mnt/etc/nixos/my-flake .#hostname
```

You will be prompted to enter a new password and shown if the install was
successful, if it was reboot.

After reboot the flake will be at `/etc/nixos/my-flake`. You can move it to your
home directory and then change the permissions:

```bash
sudo mv /etc/nixos/my-flake ~
sudo chown -R $USER:users ~/my-flake
```

Or you can clone an existing repo and just move the `disk-config.nix` and
`hardware-configuration.nix` into place.

## Impermanence

> ⚠️ Pick the correct impermanence!

1. The first rebuild after activating impermanence sometimes erases you from the
   password database. To prevent this you can run the following:

The following is a one time operation, copying all of your important files to a
persistant location.

```bash
sudo mkdir -p /persist/etc
sudo mkdir -p /persist/var/lib
sudo mkdir -p /persist/var/log
sudo mkdir -p /persist/home
sudo mkdir -p /persist/root
sudo cp -a /etc/. /persist/etc/
sudo cp -a /var/lib/. /persist/var/lib
sudo cp -a /var/log/. /persist/var/log
sudo cp -a /home/. /persist/home/
sudo cp -a /root/. /persist/root/
```

2. For impermanence, uncomment the 2 lines in the `flake.nix`. And the 1 line in
   the `configuration.nix` that imports `impermanence.nix`.

## Unencrypted impermanence.nix

This is included in the repo, just shown here for clarity. Ensure to uncomment
the line `./impermanence.nix` in the `configuration.nix` for the following
unencrypted impermanence setup:

```nix
{lib, ...}: {
  #  Reset root subvolume on boot
  boot.initrd.postResumeCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
      mount /dev/disk/by-partlabel/disk-main-root /btrfs_tmp # CONFIRM THIS IS CORRECT FROM findmnt
      if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
  '';

  # Use /persist as the persistence root, matching Disko's mountpoint
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/etc" # System configuration (Keep this here for persistence via bind-mount)
      "/var/spool" # Mail queues, cron jobs
      "/srv" # Web server data, etc.
      "/root"
    ];
    files = [
    ];
  };
}
```

## Encrypted impermanence.nix

This is included with the repo, it's just included here for clarity. Ensure that
you uncomment the line `./impermanenceLUKS.nix` for the following encrypted
impermanence setup:

This is a different way of doing things, where we take an initial snapshot of
the `root` subvolume **before** the install and reboot giving us a clean slate
to roll our system back to making it a bit more robust.

```nix
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
```

3. Apply the changes:

```bash
sudo nixos-rebuild switch --flake ~/my-flake
```

4. I recently did this and skipped the `cp -a` step and it wouldn't even let me
   reboot from the command line. However after I force shut it down and booted
   back up, it regenerated the necessary files and rebuilt without an issue.
