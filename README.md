This follows the
[minimal install guide](https://saylesss88.github.io/nix/minimal_install.html)
Follow the guide to get a minimal iso and get the internet working.

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

- Currently, the impermanence setup only works with `disk-config.nix` and will
  need to be carefully adjusted to use with the `disk-config2.nix` layout.

- If you want to simplify the encrypted install and take care of sops after
  install and reboot, just follow this guide and use `disk-config2.nix` for the
  disko command and ensure you import the correct file in the
  `configuration.nix`.

3. `initialHashedPassword`: Run `mkpasswd -m SHA-512 -s`, then enter your
   desired password. Use a unique password here as they are susceptible to brute
   force attacks. Example output:

```bash
Password: your_secret_password
Retype password: your_secret_password
$6$random_salt$your_hashed_password_string_here_this_is_very_long_and_complex
```

Copy the hashed password and use it for the value of your
`initialHashedPassword` in the `users.nix` file.

4. Run the disko command:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ~/my-flake/disk-config.nix
```

5. Check the output of `mount | grep /mnt` you should see the subvolumes listed.

6. Generate your configurations:

```bash
sudo nixos-generate-config --no-filesystems --root /mnt
```

7. Add your `networking.hostName`, git, vim, whatever else you want to your
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

1. The first rebuild after activating impermanence sometimes erases you from the
   password database. To prevent this you can run the following:

```bash
sudo cp -a /etc/* /nix/persist/etc
```

2. For impermanence, uncomment the 2 lines in the `flake.nix`. And the 1 line in
   the `configuration.nix` that imports `impermanence.nix`.

3. Apply the changes:

```bash
sudo nixos-rebuild switch --flake ~/my-flake
```

4. I recently did this and skipped the `cp -a` step and it wouldn't even let me
   reboot from the command line. However after I force shut it down and booted
   back up, it regenerated the necessary files and rebuilt without an issue.
