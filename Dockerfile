FROM alpine:latest
LABEL MAINTAINER="Christopher Kümmel" \
    Description="Simple and lightweight Samba docker container for MacOS Timemachine, based on Alpine Linux." \
    Version="1.0.0"

# upgrade base system and install samba and supervisord
RUN apk --no-cache upgrade && apk --no-cache add samba \    
    samba-common-tools \
    avahi \
    samba-client \
    samba-server \
    supervisor \
    && sed -i 's/#enable-dbus=yes/enable-dbus=no/g' /etc/avahi/avahi-daemon.conf \
    && rm -rf /var/cache/apk/*

# create a dir for the timemachine and configuration
RUN mkdir -p /backup/timemachine

# copy config files from project folder to get a default config going for samba and supervisord
COPY /config/smb.conf /etc/samba/smb.conf
COPY /config/avahia.service /etc/avahi/services/timemachine.service
COPY /config/supervisord.conf /etc/supervisord.conf

# volume mappings
VOLUME /backup/timemachine

# add user & change folder permissions
RUN addgroup -g 1000 timemachine && adduser -D -H -G timemachine -s /bin/false -u 1000 timemachine && \
    chmod 700 /backup/timemachine && \
    chown timemachine /backup/timemachine && \
    echo -e "!jIpdD52\n!jIpdD52" | smbpasswd -a -s -c /etc/samba/smb.conf timemachine


# exposes samba's default ports (137, 138 for nmbd and 139, 445 for smbd)
EXPOSE 137/udp 138/udp 139 445

HEALTHCHECK --interval=5m --timeout=3s \
  CMD (avahi-daemon -c && smbclient -L '\\localhost' -U '%' -m SMB3 &>/dev/null) || exit 1
ENTRYPOINT ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf"]