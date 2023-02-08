FROM ubuntu:20.04
# inspired by webanck/docker-wine-steam, https://github.com/mrorgues/dockerfiles, https://github.com/k3ck3c/docker_captvty, https://github.com/scottyhardy/docker-remote-desktop
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    TZ="Europe/Paris" \
    LANGUAGE="fr_FR.UTF-8" \
    LANG="fr_FR.UTF-8" \
	WINEARCH="win32" \
    WINEPREFIX="/home/ubuntu/.wine" \
    USER=root  \
    XDG_CACHE_HOME="/home/ubuntu/.cache}"
RUN apt-get update && \
    apt-get install -y \
        curl \
        mesa-utils \
        unzip  \	
        apt-transport-https \
        bzip2 \
        ca-certificates \
        gnupg \
        language-pack-en \
        language-pack-fr \
        locales \
        tzdata \
        wget \
		xauth \ 
		cabextract \ 
		winbind \ 
		squashfs-tools  \ 
		xvfb \
        dbus-x11 \
        git \
        locales \
        sudo \
        x11-xserver-utils \
        xfce4 \
        xorgxrdp \
        xrdp \
        xterm  \
        xubuntu-icon-theme 	 \
        software-properties-common  \
        --no-install-recommends && \
    echo "${TZ}" > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    locale-gen ${LANGUAGE} && \
    dpkg-reconfigure --frontend noninteractive locales && \
    dpkg --add-architecture i386 && \
    wget -nc -P /tmp https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add /tmp/winehq.key && \
    rm /tmp/winehq.key && \
    apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' && \
    add-apt-repository ppa:cybermax-dexter/sdl2-backport && \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    apt-get update && \
    apt-get install -y \
        gettext \
        libwine \		
        netcat \
        ttf-mscorefonts-installer \
        winbind \
		p11-kit:i386  \
        winehq-staging && \
	rm -rf /var/lib/apt/lists/* /var/cache/apt/* && \	
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x winetricks && \
    mv winetricks /usr/bin/winetricks && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --gid 1020 ubuntu && \
    useradd --shell /bin/bash --uid 1020 --gid 1020 --password $(openssl passwd ubuntu) --create-home --home-dir /home/ubuntu ubuntu && \
    usermod -aG sudo ubuntu && \
    mkdir -p /tmp/captvty  && \
    chown -R 1020:1020 /home/ubuntu && \
    chown -R 1020:1020 /tmp/captvty 
USER 1020
ENV PATH=$PATH:/tmp/captvty
RUN DOWNLOAD_LINK=$(curl -c /tmp/cookie http://v3.captvty.fr/ | sed -n 's/.*href="\([^"]*\).*/\1/p' | grep zip) && \
    DOWNLOAD_LINK="http:"${DOWNLOAD_LINK} && \
    wineboot --init &&\
    curl -fLo /tmp/captvty.zip  -b /tmp/cookie ${DOWNLOAD_LINK} && \
    rm /tmp/cookie && \
    mkdir /tmp/captvty/videos && \    
    unzip /tmp/captvty.zip -d /tmp/captvty && \
    rm /tmp/captvty.zip  && \
	winetricks --unattended --force win7 dotnet452 corefonts gdiplus fontsmooth=rgb &&\
    wine uninstaller --remove '{E45D8920-A758-4088-B6C6-31DBB276992E}'
USER root
COPY entrypoint.sh /usr/bin/entrypoint
COPY Captvty.config /tmp/captvty/Captvty.config
COPY Captvty.exe.config /tmp/captvty/Captvty.exe.config
EXPOSE 3389/tcp
ENTRYPOINT ["/usr/bin/entrypoint"]
