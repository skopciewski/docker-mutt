FROM archlinux:base-devel as build_aur

## Create user
RUN groupadd --gid 1010 builder \
  && useradd -m --home-dir /home/builder --uid 1010 --gid builder --shell /bin/bash --comment "" builder

RUN pacman --sync --noconfirm --refresh \
  && pacman --sync --noconfirm \
    git opensmtpd

USER builder

RUN git clone https://aur.archlinux.org/abook.git /home/builder/abook \
  && cd /home/builder/abook \
  && makepkg -src

RUN git clone https://aur.archlinux.org/procmail.git /home/builder/procmail \
  && cd /home/builder/procmail \
  && makepkg -src \
  && ls -la

# --------------------------------------------------------------------------------------------

FROM archlinux

ARG lang=pl
ARG locale=pl_PL.UTF-8
ARG timezone=Europe/Warsaw
ARG uid=1000
ARG gid=1000

COPY --from=build_aur /home/builder/abook/abook-0.6.1-7-x86_64.pkg.tar.zst /tmp/abook-0.6.1-7-x86_64.pkg.tar.zst
COPY --from=build_aur /home/builder/procmail/procmail-3.22-10-x86_64.pkg.tar.zst /tmp/procmail-3.22-10-x86_64.pkg.tar.zst

RUN pacman --sync --noconfirm --refresh \
 && sed -i -e '/locale/d' -e '/lang/d' /etc/pacman.conf \
 && pacman --sync --noconfirm \
    curl \
    elinks \
    git \
    glibc \
    less \
    neomutt \
    ruby \
    urlscan \
    vim \
 && pacman --noconfirm -U /tmp/abook-0.6.1-7-x86_64.pkg.tar.zst \
 && pacman --noconfirm -U /tmp/procmail-3.22-10-x86_64.pkg.tar.zst \
 && rm -rf /var/lib/pacman

# download vim dics
RUN mkdir -p /opt/vim/spell \
    && curl -o /opt/vim/spell/${lang}.utf-8.spl -fsSL \
      "ftp://ftp.vim.org/pub/vim/runtime/spell/${lang}.utf-8.spl"

# Set locale
RUN cp /etc/locale.gen.pacnew /etc/locale.gen
RUN sed -i -e "s/.*pl_PL\(.*\)/pl_PL\1/" /etc/locale.gen && locale-gen
RUN echo "LANG=${locale}" > /etc/locale.conf
RUN echo "export LANG=${locale}" >> /etc/skel/.profile
RUN echo "export TERM=screen-256color" >> /etc/skel/.profile
RUN ln -s -f /usr/share/zoneinfo/${timezone} /etc/localtime
ENV LANG=${locale}
ENV LC_ALL=${locale}
ENV TERM=screen-256color

# Create user
RUN groupadd --gid ${gid} muttuser \
  && useradd -m --home-dir /home/muttuser --uid ${uid} --gid muttuser --shell /bin/bash --comment "" muttuser

# Install gems
RUN gem install --no-user-install -n /usr/local/bin -N mayaml-mutt -v '~> 4.1'

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
