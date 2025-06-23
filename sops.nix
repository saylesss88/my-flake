{...}: {
  sops = {
    defaultSopsFile = ./sops.yaml; # Or the correct path to your .sops.yaml
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    # Correct paths as needed
    age.keyFile = "/home/nixos/sops/age/keys.txt";

    secrets = {
      "password_hash" = {
        sopsFile = ./secrets/password-hash.yaml; # <-- Points to your password hash file
        owner = "root";
        group = "root";
        mode = "0400";
        neededForUsers = true;
      };
      "github_deploy_key_ed25519" = {
        sopsFile = ./secrets/github-deploy-key.yaml;
        key = "github_deploy_key_ed25519";
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };
  };
}
