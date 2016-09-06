FROM fedora:24

ARG lang=pl
ARG locale=pl_PL.utf8

# grab gosu for easy step-down from root
RUN curl -o /usr/local/bin/gosu -fsSL \
      "https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64" \
    && chmod +x /usr/local/bin/gosu 

# Install all stuff and cleanup
RUN dnf -y install dnf-plugins-core \
    && dnf -y copr enable flatcap/neomutt \
    && dnf -y install \
      abook \
      cyrus-sasl-gssapi \
      cyrus-sasl-md5 \
      cyrus-sasl-plain \
      elinks \
      git \
      langpacks-${lang} \
      neomutt \
      ruby \
      vim \
    && rm -rf /var/cache/dnf/*

# Set locale
RUN echo "LANG=${locale}" > /etc/locale.conf
RUN echo "export LANG=${locale}" >> /etc/skel/.bash_profile
RUN echo "export TERM=screen-256color" >> /etc/skel/.bash_profile
ENV LANG=${locale}
ENV LC_ALL=${locale}
ENV TERM=screen-256color

# Install gems
RUN gem install -N mayaml-mutt \
    && rm -rf /usr/local/share/gems/cache/*

# vim config
COPY data/vim/vimrc /root/.vimrc
RUN mkdir -p /root/.vim/undo /root/.vim/swap \
    && git clone https://github.com/gmarik/Vundle.vim.git /root/.vim/bundle/Vundle.vim \
    && sed -e '/^colorscheme/s/.*/"\\1/' /root/.vimrc > /tmp/vimrc \
    && vim --not-a-term -u /tmp/vimrc +VundleInstall +qall &> /dev/null \
    && rm /tmp/vimrc

# env
ENV MUTT_USER_ID=1000
ENV MUTT_GROUP_ID=1000
ENV MUTT_CONF_DIR=/opt/mutt
ENV MUTT_MAILS_DIR=/mnt/mails
ENV MUTT_ABOOK_DIR=/mnt/abook
ENV MAYAML_FILE=/mnt/mayaml.yml

# mutt config
RUN mkdir -p ${MUTT_CONF_DIR}
COPY data/mutt ${MUTT_CONF_DIR}

# entrypoint
COPY data/entrypoint /entrypoint
RUN chmod 755 /entrypoint

VOLUME ["${MUTT_MAILS_DIR}", "%{MUTT_ABOOK_DIR}"]
ENTRYPOINT ["/entrypoint"]
CMD ["all"]
