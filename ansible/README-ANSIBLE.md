# Ansible Role for Todo App VM Setup

This Ansible role sets up a VM to run the Todo application with Docker, Docker Compose, and Kubernetes components.

## Features

- **Package Installation**: Installs all required system packages
- **Docker Setup**: Installs Docker CE and Docker Compose
- **Kubernetes Tools**: Installs kubectl and Minikube for local Kubernetes
- **Security**: Configures UFW firewall with proper rules
- **Auto-update**: Moves auto-update script to container and sets up cron job
- **Secure Credentials**: Uses Ansible Vault for Docker credentials

## Prerequisites

- Ansible 2.9+
- Target VM with Ubuntu/Debian
- SSH access to target VM
- Docker Hub credentials

## Quick Start

1. **Update inventory**:
   ```bash
   # Edit inventory.yml with your VM details
   vim inventory.yml
   ```

2. **Set up Docker credentials**:
   ```bash
   # Edit credentials (replace with your actual credentials)
   vim vars/docker-credentials.yml
   
   # Encrypt the credentials file
   ansible-vault encrypt vars/docker-credentials.yml
   ```

3. **Run the playbook**:
   ```bash
   # Run with vault password
   ansible-playbook -i inventory.yml playbook.yml --ask-vault-pass
   
   # Or with vault password file
   echo "your-vault-password" > .vault_pass
   chmod 600 .vault_pass
   ansible-playbook -i inventory.yml playbook.yml --vault-password-file .vault_pass
   ```

## Security Features

### Docker Credentials
- Credentials are stored in encrypted Ansible Vault
- Docker config is created with proper permissions (600)
- Credentials are base64 encoded for Docker authentication

### Firewall Configuration
- UFW firewall enabled with deny policy
- Only necessary ports open (22, 4000, 27017)
- SSH access maintained

### File Permissions
- Application files owned by user
- Docker credentials directory: 700
- Docker config file: 600

## Auto-Update System

The role includes an enhanced auto-update system:

- **Cron Job**: Runs every 2 minutes
- **Health Checks**: Monitors container restart count and status
- **Rollback**: Automatically rolls back if new version is unhealthy
- **Logging**: All updates logged to `/var/log/auto-update.log`

## Directory Structure

```
/opt/todo-app/
├── .docker/
│   └── config.json          # Docker credentials
├── auto-update-image.sh     # Auto-update script
├── docker-compose.yml       # Application compose file
├── assets/                  # Application assets
├── controllers/             # Application controllers
├── models/                  # Application models
├── routes/                  # Application routes
└── views/                   # Application views
```

## Monitoring

### Check Application Status
```bash
# SSH to VM
ssh user@vm-ip

# Check container status
cd /opt/todo-app
docker compose ps

# Check auto-update logs
tail -f /var/log/auto-update.log

# Check cron job
crontab -l
```

### Kubernetes Access
```bash
# Start Minikube (if needed)
minikube start

# Access kubectl
kubectl get pods
```

## Troubleshooting

### Common Issues

1. **Docker permission denied**:
   ```bash
   # Add user to docker group (role handles this)
   sudo usermod -aG docker $USER
   newgrp docker
   ```

2. **Firewall blocking access**:
   ```bash
   # Check UFW status
   sudo ufw status
   
   # Allow specific port if needed
   sudo ufw allow 4000
   ```

3. **Auto-update not working**:
   ```bash
   # Check cron job
   crontab -l
   
   # Check logs
   tail -f /var/log/auto-update.log
   
   # Test script manually
   cd /opt/todo-app && ./auto-update-image.sh
   ```

## Variables

### Required Variables
- `docker_username`: Docker Hub username
- `docker_password`: Docker Hub password

### Optional Variables
- `app_port`: Application port (default: 4000)
- `mongo_port`: MongoDB port (default: 27017)
- `firewall_enabled`: Enable firewall (default: true)
- `auto_update_enabled`: Enable auto-update (default: true)
- `auto_update_interval`: Cron interval (default: "*/2")

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `ansible-lint`
5. Submit a pull request

## License

MIT License - see LICENSE file for details. 