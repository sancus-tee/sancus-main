
# apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common

# curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -

# add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"

# apt-get update

# apt-get install docker-ce

# vi /etc/group ; add relevant users to docker group

$ docker run hello-world

// "This message shows that your installation appears to be working correctly."

$ make build
$ make run


