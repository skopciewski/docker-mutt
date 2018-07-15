FROM base/archlinux

ARG lang=pl
ARG locale=pl_PL.UTF-8
ARG timezone=Europe/Warsaw

# grab gosu for easy step-down from root
RUN curl -o /usr/local/bin/gosu -fsSL \
      "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" \
    && chmod +x /usr/local/bin/gosu 

# download vim dics
RUN mkdir -p /opt/vim/spell \
    && curl -o /opt/vim/spell/${lang}.utf-8.spl -fsSL \
      "ftp://ftp.vim.org/pub/vim/runtime/spell/${lang}.utf-8.spl"

# download extract_url.pl
RUN curl -o /usr/local/sbin/extract_url.pl -fsSL \
      "https://raw.githubusercontent.com/m3m0ryh0l3/extracturl/master/extract_url.pl" \
    && chmod +x /usr/local/sbin/extract_url.pl

# Install all stuff and cleanup
RUN pacman -Sy \
    && pacman -S --noconfirm \
      abook \
      cyrus-sasl-gssapi \
      elinks \
      git \
      neomutt \
      perl-html-parser \
      perl-mime-tools \
      perl-uri \
      procmail \
      ruby \
      vim \
    && pacman -S --noconfirm \
      m4 \
      autoconf \
      automake \
      patch \
      wget \
      sudo \
      binutils \
      gcc \
      make \
      fakeroot \
    && useradd builduser -m \
    && passwd -d builduser \
    && printf 'builduser ALL=(ALL) ALL\n' | tee -a /etc/sudoers \
    && sudo -u builduser bash -c 'cd ~ && wget https://aur.archlinux.org/cgit/aur.git/snapshot/urlview.tar.gz && tar xzf urlview.tar.gz && cd urlview && makepkg -is --noconfirm' \
    && userdel builduser \
    && rm -rf /home/builduser \
    && pacman --noconfirm -Rs m4 autoconf automake patch wget sudo binutils gcc make fakeroot \
    && pacman -Scc --noconfirm \
    && rm -r /var/lib/pacman/sync/*


# Set locale
RUN sed -i -e "s/.*pl_PL\(.*\)/pl_PL\1/" /etc/locale.gen && locale-gen
RUN echo "LANG=${locale}" > /etc/locale.conf
RUN echo "export LANG=${locale}" >> /etc/skel/.bash_profile
RUN echo "export TERM=screen-256color" >> /etc/skel/.bash_profile
RUN /usr/bin/ln -s -f /usr/share/zoneinfo/${timezone} /etc/localtime
ENV LANG=${locale}
ENV LC_ALL=${locale}
ENV TERM=screen-256color

# Install gems
RUN gem install --no-user-install -n /usr/local/bin -N mayaml-mutt -v '~> 4'

# vim config
COPY data/vim/vimrc /root/.vimrc
RUN mkdir -p /root/.vim/undo /root/.vim/swap \
    && git clone https://github.com/gmarik/Vundle.vim.git /root/.vim/bundle/Vundle.vim \
    && sed -e '/^colorscheme/s/.*/"\\1/' /root/.vimrc > /tmp/vimrc \
    && vim --not-a-term -u /tmp/vimrc +VundleInstall +qall &> /dev/null \
    && rm /tmp/vimrc \
    && ln -sf /opt/vim/spell /root/.vim/spell

# env
ENV MUTT_USER_ID=1000
ENV MUTT_GROUP_ID=1000
ENV MUTT_CONF_DIR=/opt/mutt
ENV MUTT_MAILS_DIR=/mnt/mails
ENV MUTT_ABOOK_DIR=/mnt/abook
ENV MUTT_HOST_DIR=/mnt/host
ENV MAYAML_FILE=/mnt/mayaml.yml

# mutt config
RUN mkdir -p ${MUTT_CONF_DIR}
COPY data/mutt ${MUTT_CONF_DIR}

# mutt host dir
RUN mkdir -p ${MUTT_HOST_DIR}

# entrypoint
COPY data/entrypoint /entrypoint
RUN chmod 755 /entrypoint

ENTRYPOINT ["/entrypoint"]
CMD ["all"]
