FROM bitnami/minideb:stretch

ARG lang=pl
ARG locale=pl_PL.UTF-8
ARG timezone=Europe/Warsaw
ARG uid=1000
ARG gid=1000

RUN echo "deb http://http.us.debian.org/debian testing main non-free contrib" > /etc/apt/sources.list.d/testing.list \
    && echo "deb-src http://http.us.debian.org/debian testing main non-free contrib" >> /etc/apt/sources.list.d/testing.list

RUN install_packages \
      abook \
      curl \
      elinks \
      git \
      less \
      libenv-path-perl \
      libhtml-parser-perl \
      libmime-tools-perl \
      libsasl2-modules-gssapi-mit \
      liburi-perl \
      locales \
      neomutt \
      procmail \
      ruby \
      urlscan \
      urlview \
      vim 

# download vim dics
RUN mkdir -p /opt/vim/spell \
    && curl -o /opt/vim/spell/${lang}.utf-8.spl -fsSL \
      "ftp://ftp.vim.org/pub/vim/runtime/spell/${lang}.utf-8.spl"

# download extract_url.pl
RUN curl -o /usr/local/sbin/extract_url.pl -fsSL \
      "https://raw.githubusercontent.com/m3m0ryh0l3/extracturl/master/extract_url.pl" \
    && chmod +x /usr/local/sbin/extract_url.pl

# Set locale
RUN sed -i -e "s/.*pl_PL\(.*\)/pl_PL\1/" /etc/locale.gen && locale-gen
RUN echo "export LANG=${locale}" >> /etc/profile
RUN echo "export LANG=${locale}" >> /etc/skel/.profile
RUN echo "export TERM=screen-256color" >> /etc/skel/.profile
RUN ln -s -f /usr/share/zoneinfo/${timezone} /etc/localtime
ENV LANG=${locale}
ENV LC_ALL=${locale}
ENV TERM=screen-256color

# Create user
RUN addgroup --gid ${gid} muttuser \
  && adduser --home /home/muttuser --disabled-password --uid ${uid} --ingroup muttuser --shell /bin/bash --gecos "" muttuser

# Install gems
RUN gem install --no-user-install -n /usr/local/bin -N mayaml-mutt -v '~> 4'

# env
ENV MUTT_MAILS_DIR=/mnt/mails
ENV MUTT_ABOOK_DIR=/mnt/abook
ENV MUTT_HOST_DIR=/mnt/host
ENV MAYAML_FILE=/mnt/mayaml.yml

# mutt dirs
RUN mkdir -p ${MUTT_HOST_DIR} \
  && mkdir -p ${MUTT_ABOOK_DIR} \
  && mkdir -p ${MUTT_MAILS_DIR}

# entrypoint
COPY data/entrypoint /entrypoint
RUN chmod 755 /entrypoint

USER muttuser

# vim config
COPY --chown=muttuser:muttuser data/vim/vimrc /home/muttuser/.vimrc
RUN mkdir -p /home/muttuser/.vim/undo /home/muttuser/.vim/swap \
  && git clone https://github.com/gmarik/Vundle.vim.git /home/muttuser/.vim/bundle/Vundle.vim \
  && sed -e '/^colorscheme/s/.*/"\\1/' /home/muttuser/.vimrc > /tmp/vimrc \
  && /bin/bash -c 'vim --not-a-term -u /tmp/vimrc +VundleInstall +qall &> /dev/null' \
  && rm /tmp/vimrc \
  && ln -sf /opt/vim/spell /home/muttuser/.vim/spell

# mutt config
COPY --chown=muttuser:muttuser data/mutt /home/muttuser/.mutt
RUN ln -sf ${MUTT_MAILS_DIR} /home/muttuser/.mails \
  && ln -sf ${MUTT_ABOOK_DIR} /home/muttuser/.abook

ENTRYPOINT ["/entrypoint"]
CMD ["all"]
