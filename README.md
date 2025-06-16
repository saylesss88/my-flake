- Change all the spots labeled `# Change me!`. The repo defaults to `nixos` for
  the hostname and `my-user` for the user.

- `initialHashedPassword`: Run `mkpasswd -m SHA-512 -s`, then enter your desired
  password. Example output,

```bash
Password: your_secret_password
Retype password: your_secret_password
$6$random_salt$your_hashed_password_string_here_this_is_very_long_and_complex
```

Copy the hashed password and use it for the value of your
`initialHashedPassword` in the `users.nix` file.

- After cloning, you'll probably want to delete the `.git` directory and run
  your own `git init`. This is just a minimal flake repo nothing extensive.

- Make sure to generate your own `hardware-configuration.nix`.

- Make sure you know which disk you are using in `disk-config.nix` and change it
  accordingly.

- After everything is in place, move this Flake repo to `/mnt/etc/nixos`.
