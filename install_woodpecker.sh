#!/bin/bash

# arg validation
if [ "$#" -ne 1 ]; then
    echo "necessary arguments: <domain>"
    exit 1
fi

# common regex
valid_domain_regex='^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$'


# validating domain
if [[ "$1" =~ $valid_domain_regex ]]; then
    REALM="$1"
else
    echo "Error: '$1' is not a valid realm"
    exit 2
fi

# function to debug
check_code() {
    local code="$1"
    local msg="$2"
    if [ "$code" -ne 0 ]; then
        echo "Error ($code): $msg"
        exit "$code"
    fi
}

apt update
check_code $? "Updating apt"

DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  upgrade -fy
check_code $? "Upgrading"

DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  install -y  curl openssl docker.io docker-compose
check_code $? "Installing"

useradd --system --no-create-home woodpecker
usermod -aG docker woodpecker

RELEASE_VERSION=$(curl -s https://api.github.com/repos/woodpecker-ci/woodpecker/releases/latest | grep -Po '"tag_name":\s"v\K[^"]+')
check_code $? "Getting release version"

curl -fLOOO "https://github.com/woodpecker-ci/woodpecker/releases/download/v${RELEASE_VERSION}/woodpecker-{server,agent,cli}_${RELEASE_VERSION}_amd64.deb"
check_code $? "Downloading deb"

dpkg -i ./woodpecker-{server,agent,cli}_${RELEASE_VERSION}_amd64.deb
apt install -f


AGENT_SECRET=$(openssl rand -hex 32)

echo "WOODPECKER_LOG_LEVEL=error
WOODPECKER_OPEN=true
WOODPECKER_HOST=http://$REALM:8000

WOODPECKER_FORGEJO=true
WOODPECKER_FORGEJO_URL=http://forgejo.local:3000
WOODPECKER_FORGEJO_CLIENT=
WOODPECKER_FORGEJO_SECRET=

WOODPECKER_AGENT_SECRET=$AGENT_SECRET" > /etc/woodpecker/woodpecker-server.env

echo "WOODPECKER_SERVER=localhost:9000
WOODPECKER_BACKEND=docker
WOODPECKER_AGENT_SECRET=$AGENT_SECRET" > /etc/woodpecker/woodpecker-agent.env


systemctl enable --now woodpecker-server.service
systemctl enable --now woodpecker-agent.service

echo "Finish!"
echo "Please configure your FORGEJO settings: (/etc/woodpecker/woodpecker-server.env)"
echo "  WOODPECKER_FORGEJO_CLIENT="
echo "  WOODPECKER_FORGEJO_SECRET="
echo "and restart server: systemctl restart woodpecker-server.service"
echo "Web access: http://$REALM:8000"

exit 0
