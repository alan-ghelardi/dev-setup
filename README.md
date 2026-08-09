# dev-setup

Automated development environment setup for Linux systems, providing installation scripts and configuration files for a comprehensive cloud-native development toolchain.

## Overview

This repository automates the provisioning of a complete development environment with support for multiple Linux distributions (Arch Linux, Ubuntu) and VMware virtualization. It includes installation scripts for 35+ development tools, shell configuration files, and system setup automation.

## Project Structure

```
dev-setup/
├── bin/                         # Core installation and setup scripts
├── dev-tools/                   # Individual tool installation scripts (35+)
├── dotfiles/                    # Shell configuration and dotfiles
├── archlinux/                   # Arch Linux-specific setup files
├── ubuntu/                      # Ubuntu-specific setup files
└── vmware/                      # VMware systemd service files
```

## Prerequisites

- Linux system (Arch Linux or Ubuntu)
- Internet connection for downloading tools and dependencies
- sudo/root access for system-level installations

## Quick Start

### Installing All Development Tools

Run the main installation script to install all development tools:

```bash
./bin/install-dev-tools.sh
```

This script iterates through all tool installers in the `dev-tools/` directory and executes them sequentially.

### Setting Up Shell Configuration

Create symbolic links for dotfiles in your home directory:

```bash
./bin/create-symblinks.sh
```

Then source the RC file in your shell configuration (e.g., `.bashrc` or `.zshrc`):

```bash
source ~/dev-setup/dotfiles/.rc.sh
```

## Included Development Tools

### Cloud & Infrastructure
- AWS CLI, IAM Authenticator, EKS CLI
- Terraform (1.2.2), Pulumi, Kustomize

### Container & Kubernetes
- containerd, kubectl, KinD, Helm (3.11.3)
- Istio, Tekton CLI, Kubeseal, kubeval
- Kube Builder, Container Structure Test

### Programming Languages & Runtimes
- Go (1.26.1)
- Node.js (via NVM)
- Clojure & Leiningen
- Java Development Kit 11

### Code Quality & Build Tools
- golangci-lint, go-swagger
- Protocol Buffers compiler, gRPC tools
- jq, yq

### Specialized Tools
- Gremlin (chaos engineering)
- Cosign (container signing)
- Claude Code CLI
- notation, Spot control, KCL

## Distribution-Specific Setup

### Arch Linux

For fresh Arch Linux installations, use the provided ALIS (Arch Linux Install Script) configuration:

1. Configure installation parameters in `archlinux/alis.conf`
2. Run ALIS with the configuration
3. After base installation, execute post-installation setup:

```bash
./archlinux/post-install.sh
```

The configuration includes LUKS encryption, BTRFS subvolumes, and MATE desktop environment setup.

### Ubuntu

Install Docker on Ubuntu:

```bash
./ubuntu/docker.sh
```

This script adds Docker's official repository, installs Docker Engine, and configures user permissions.

## Configuration Files

### Environment Variables

`dotfiles/.env.sh` contains centralized environment configuration:
- PATH extensions for local binaries and Go
- Editor preferences (Emacs)
- GitHub and OpenAI API keys
- Go, Java, Kubernetes, and Node.js configurations
- GPG signing setup for Git commits

### Shell Integration

`dotfiles/.rc.sh` provides shell initialization:
- Sources environment variables
- Loads helper functions
- Integrates shell completions
- Configures Homebrew integration

### Git Configuration

`dotfiles/conf/.gitconfig` includes:
- User identity configuration
- GPG commit signing enabled
- SSH URL rewrites for GitHub

## VMware Integration

For VMware environments, install the systemd service files:

```bash
sudo cp vmware/*.service /etc/systemd/system/
sudo systemctl enable vmware.service vmware-networks-server.service
sudo systemctl start vmware.service vmware-networks-server.service
```

## Helper Functions

The repository includes shell helper functions in `dotfiles/helpers/`:
- `microphone.sh` - Audio testing utility for recording and playback
- `tekton-results.sh` - Tekton pipeline results helpers

## Installation Scripts

Each tool in `dev-tools/` has its own installation script that:
- Downloads the tool from official sources
- Verifies checksums where applicable
- Installs to appropriate system locations
- Is idempotent (safe to run multiple times)

Scripts follow the naming pattern `install-<tool-name>.sh`.

## Notes

- Installation scripts download specific versions of tools to ensure consistency
- Some scripts verify downloads using SHA1 checksums for security
- The JDK installer downloads from an S3 bucket and requires credentials
- Configuration files assume Emacs as the primary editor
- Git is configured for GPG signing of commits
- Shell completions are automatically loaded for supported tools

## Target Use Cases

This environment is optimized for:
- Cloud-native application development
- Kubernetes cluster management and operations
- Infrastructure as Code (Terraform, Pulumi)
- Container-based development workflows
- Go and Node.js development
- gRPC and Protocol Buffer development
- DevOps and SRE workflows
