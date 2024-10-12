```markdown
# ELK Stack Setup Guide on Ubuntu 20.04 LTS (4 vCPU, 8 GB RAM)

## Prerequisites:
- Ubuntu 20.04 LTS with 4 vCPUs and 8 GB of RAM (minimum for ELK stack).
- Sudo privileges.

---

## 1. Install Docker

### Step 1: Update the package list
```bash
sudo apt update
```

### Step 2: Install required packages
```bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

### Step 3: Add Docker’s official GPG key
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

### Step 4: Add Docker’s official repository
```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Step 5: Update the package list again
```bash
sudo apt update
```

### Step 6: Install Docker
```bash
sudo apt install docker-ce docker-ce-cli containerd.io
```

### Step 7: Verify Docker installation
```bash
docker --version
```

### Step 8: Start and enable Docker
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

---

## 2. Install Docker Compose

### Step 1: Download the latest Docker Compose release
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/2.12.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

### Step 2: Set executable permissions
```bash
sudo chmod +x /usr/local/bin/docker-compose
```

### Step 3: Verify Docker Compose installation
```bash
docker-compose --version
```

---

## 3. Install Git

### Step 1: Install Git
```bash
sudo apt install git
```

### Step 2: Verify Git installation
```bash
git --version
```

---
```