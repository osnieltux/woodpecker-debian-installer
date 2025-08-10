# woodpecker-debian-installer
Script to facilitate the installation of [Woodpecker](https://woodpecker-ci.org/).
This script by default creates a basic configuration for [Forgejo](https://forgejo.org/) that you will need to finish configuring.
Tested on Debian 12

### 🚀 Install example (change <your_domain> for your real domain)
    curl -fsSL https://raw.githubusercontent.com/osnieltux/woodpecker-debian-installer/refs/heads/main/install_woodpecker.sh | bash -s -- <your_domain>

### 🪛 Configure your /etc/woodpecker/woodpecker-server.env
   -  go to http://<forgejo_ip>:3000/user/settings/applications
   -  create your OAuth2
   -  set your URIs http://<your_woodpecker_domain>:8000/authorize
   -  WOODPECKER_FORGEJO_URL=http://<forgejo_ip>:3000/
   -  WOODPECKER_FORGEJO_CLIENT=
   -  WOODPECKER_FORGEJO_SECRET=
    
### 🗺️ Access
   - http://<your_domain><your_domain>:8000
