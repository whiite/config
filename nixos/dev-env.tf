terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.3.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 19.1.0"
    }
    gitea = {
      source  = "go-gitea/gitea"
      version = "~> 0.8.1"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.29.0"
    }
  }
}

# --- Variables ---
variable "remote_host" {
  type        = string
  default     = "nixos"
  description = "Host name for machine for use with SSH - with Tailscale use the configured name"
}
variable "remote_user" {
  type    = string
  default = "liam"
}
variable "remote_password" {
  type      = string
  default   = null
  sensitive = true
}
variable "github_token" {
  type        = string
  description = <<-EOT
   Requires permissions:
   - git SSH keys: Read & Write
   - git signing SSH keys: Read & Write
   - profile: Read & Write
  EOT
}
variable "gitlab_token" {
  type        = string
  description = <<-EOT
    Requires permissions:
    User > System Access:
    - User: Read
    - SSH Key: Create, Read, Delete
  EOT
}
variable "gitea_http_url" {
  type = string
}
variable "gitea_ssh_url" {
  type = string
}
variable "gitea_token" {
  type        = string
  description = <<-EOT
    Requires permissions:
    - admin: Read and Write
    - user: Read
  EOT
}
variable "ssh_algo" {
  type    = string
  default = "ED25519"
}
variable "key_label" {
  type    = string
  default = "Eldin - NixOS VM"
}
variable "tailscale_api_key" {
  type        = string
  sensitive   = true
  description = <<-EOT
    Tailscale API key used by the provider to mint a tailnet auth key.
    Generate one at https://login.tailscale.com/admin/settings/api
    Supply via terraform.tfvars or the TF_VAR_tailscale_api_key env var.
  EOT
}
variable "tailscale_tailnet" {
  type        = string
  description = "Tailnet name, derived from the configured gitea URL"
}

# --- Provider Config ---
provider "github" {
  token = var.github_token
}

provider "gitlab" {
  token = var.gitlab_token
}

provider "gitea" {
  base_url = "https://${var.gitea_http_url}"
  token    = var.gitea_token
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailscale_tailnet
}

locals {
  nixos_flake_file = "${path.module}/flake.nix"
  nixos_lock_file  = "${path.module}/flake.lock"
  # hardware-configuration.nix lives alongside the flake so the deployed flake
  # tree is self-contained. It is installed outside the /etc/nixos bind mount
  # to avoid pulling the shared repo (and .terraform) into the Nix store.
  nixos_hardware_file = "${path.module}/hardware-configuration.nix"
  remote_flake_dir    = "/etc/nixos-flake"
}

# --- Tailscale auth key ---
# Created automatically so the VM can register itself on first boot without an
# interactive `tailscale up`. Deployed to /etc/tailscale-authkey by the rebuild.
resource "tailscale_tailnet_key" "vm_auth" {
  reusable            = true
  ephemeral           = false
  preauthorized       = true
  recreate_if_invalid = "always"
  description         = "NixOS VM auto-registration"
}

# --- Deploy & apply the NixOS configuration ---
resource "terraform_data" "nixos_apply" {
  # Re-deploy + re-apply whenever the local flake (or the auth key) changes
  triggers_replace = [
    filesha256(local.nixos_flake_file),
    filesha256(local.nixos_lock_file),
    filesha256(local.nixos_hardware_file),
    tailscale_tailnet_key.vm_auth.id,
  ]

  connection {
    type     = "ssh"
    user     = var.remote_user
    host     = var.remote_host
    password = var.remote_password
  }

  # 1. Copy the flake + hardware config across (runs as the SSH user, so /tmp first)
  provisioner "file" {
    source      = local.nixos_flake_file
    destination = "/tmp/flake.nix"
  }

  provisioner "file" {
    source      = local.nixos_lock_file
    destination = "/tmp/flake.lock"
  }

  provisioner "file" {
    source      = local.nixos_hardware_file
    destination = "/tmp/hardware-configuration.nix"
  }

  # 2. Provision the auth key, install the flake and rebuild
  provisioner "remote-exec" {
    inline = [
      # Auth key must exist before the rebuild activates tailscaled-autoconnect
      "sudo install -m 0600 -o root -g root /dev/null /etc/tailscale-authkey",
      "printf '%s' '${tailscale_tailnet_key.vm_auth.key}' | sudo tee /etc/tailscale-authkey >/dev/null",
      "sudo chmod 0600 /etc/tailscale-authkey",

      "sudo -n nix-channel --add https://channels.nixos.org/nixos-26.05 nixos",
      "sudo nix-channel --update",
      # Install the flake into a clean directory so Nix does not copy the
      # shared (git-backed, 216MB .terraform) repo into the store.
      "sudo mkdir -p ${local.remote_flake_dir}",
      "sudo install -m 0644 /tmp/flake.nix ${local.remote_flake_dir}/flake.nix",
      "sudo install -m 0644 /tmp/flake.lock ${local.remote_flake_dir}/flake.lock",
      "sudo install -m 0644 /tmp/hardware-configuration.nix ${local.remote_flake_dir}/hardware-configuration.nix",
      "sudo nixos-rebuild switch --flake path:${local.remote_flake_dir}#nixos",
      "rm -f /tmp/flake.nix /tmp/flake.lock /tmp/hardware-configuration.nix",
    ]
  }
}

# 1. Generate SSH Keys
resource "tls_private_key" "github" {
  algorithm = var.ssh_algo
}
resource "tls_private_key" "gitlab" {
  algorithm = var.ssh_algo
}
resource "tls_private_key" "gitea" {
  algorithm = var.ssh_algo
}
resource "tls_private_key" "signing" {
  algorithm = var.ssh_algo
}

# Configure keys in GitHub
locals {
  key_label_signing = "${var.key_label} (signing)"
}

resource "github_user_ssh_key" "github_auth" {
  title = var.key_label
  key   = resource.tls_private_key.github.public_key_openssh
}

# NOTE: There is no way choose between an auth key and a signing key so this key
# will only act as a auth key in GitHub
# PR to solve this issue: https://github.com/integrations/terraform-provider-github/pull/2366
#
# resource "github_user_ssh_key" "github_signing" {
#   title = local.key_label_signing
#   key   = resource.tls_private_key.signing.public_key_openssh
# }

# Temporary workaround:
resource "null_resource" "github_signing_key_upload" {
  triggers = {
    key_id = tls_private_key.signing.id
  }

  provisioner "local-exec" {
    # Key must be saved to a file for the gh CLI to add
    command = <<-EOT
      echo "${tls_private_key.signing.public_key_openssh}" > /tmp/signing.pub
      GITHUB_TOKEN="${var.github_token}" gh ssh-key add /tmp/signing.pub \
        --type "signing" \
        --title "${local.key_label_signing}"
      rm /tmp/signing.pub
    EOT
  }
}


# Configure keys in GitLab
resource "gitlab_user_sshkey" "gitlab_auth" {
  title = var.key_label
  key   = resource.tls_private_key.gitlab.public_key_openssh
}

# NOTE: There is no way currently to differentiate between an auth key and a
# signing key so this key will serve as both in GitLab
resource "gitlab_user_sshkey" "gitlab_signing" {
  title = local.key_label_signing
  key   = resource.tls_private_key.signing.public_key_openssh
}

# Configure keys in Gitea
data "gitea_user" "current" {
  # username = "whiite"
}

resource "gitea_public_key" "gitea_auth" {
  title     = var.key_label
  key       = resource.tls_private_key.gitea.public_key_openssh
  username  = data.gitea_user.current.username
  read_only = false
}

resource "gitea_public_key" "gitea_signing" {
  title     = local.key_label_signing
  key       = resource.tls_private_key.signing.public_key_openssh
  username  = data.gitea_user.current.username
  read_only = false
}

# Deploy Keys and Config to Remote Machine
resource "null_resource" "setup_service_ssh" {
  connection {
    type     = "ssh"
    user     = var.remote_user
    host     = var.remote_host
    password = var.remote_password
  }

  triggers = {
    github         = tls_private_key.github.id
    gitlab         = tls_private_key.gitlab.id
    gitea          = tls_private_key.gitea.id
    signing        = tls_private_key.signing.id
    gitea_ssh_host = var.gitea_ssh_url
    nixos_flake    = filesha256(local.nixos_flake_file),
  }

  depends_on = [
    terraform_data.nixos_apply
  ]

  # NOTE: if this hangs - may need to re-authenticate with tailscale
  # Try a regular ssh to the tailscale domain
  provisioner "remote-exec" {

    inline = [
      "mkdir -p ~/.ssh && chmod 700 ~/.ssh",

      # Deploy Private Keys
      "echo '${resource.tls_private_key.github.private_key_pem}' > ~/.ssh/id_ed25519_github",
      "echo '${resource.tls_private_key.github.public_key_openssh}' > ~/.ssh/id_ed25519_github.pub",

      "echo '${resource.tls_private_key.gitlab.private_key_pem}' > ~/.ssh/id_ed25519_gitlab",
      "echo '${resource.tls_private_key.gitlab.public_key_openssh}' > ~/.ssh/id_ed25519_gitlab.pub",

      "echo '${resource.tls_private_key.gitea.private_key_pem}' > ~/.ssh/id_ed25519_gitea",
      "echo '${resource.tls_private_key.gitea.public_key_openssh}' > ~/.ssh/id_ed25519_gitea.pub",


      "echo '${resource.tls_private_key.signing.private_key_pem}' > ~/.ssh/id_ed25519_signing",
      "echo '${resource.tls_private_key.signing.public_key_openssh}' > ~/.ssh/id_ed25519_signing.pub",
      "chmod 600 ~/.ssh/id_*",

      # SSH Config for routing
      <<-EOT
        cat <<EOF > ~/.ssh/config
        # Managed by OpenTofu - do not save SSH hosts here manually
        Host github.com
          IdentityFile ~/.ssh/id_ed25519_github

        Host gitlab.com
          IdentityFile ~/.ssh/id_ed25519_gitlab

        Host ${var.gitea_ssh_url}
          IdentityFile ~/.ssh/id_ed25519_gitea
        EOF
      EOT
      ,
      "chmod 600 ~/.ssh/config",

      # Git Global Config for SSH Signing
      "git config --global user.signingkey ~/.ssh/id_ed25519_signing",
      "git config --global gpg.format ssh",
      "git config --global commit.gpgsign true",
    ]
  }
}
