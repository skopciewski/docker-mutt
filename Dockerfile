FROM alpine:3

ARG uid=1000
ARG gid=1000
ARG user=muttuser

ENV TZ Europe/Warsaw
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8
ENV TERM screen-256color

RUN echo 'export LANG="C.UTF-8"' > /etc/profile.d/lang.sh \
  && apk add --no-cache --update tzdata zsh bash zsh-vcs \
  && cp /usr/share/zoneinfo/Europe/Warsaw /etc/localtime \
  && apk del tzdata \
  && mv /etc/profile.d/color_prompt.sh.disabled /etc/profile.d/color_prompt.sh \
  && addgroup -g ${gid} ${user} \
  && adduser -h /home/${user} -D -u ${uid} -G ${user} -s /bin/zsh ${user}

RUN apk add --no-cache --update \
  abook \
  ack \
  curl \
  elinks \
  git \
  less \
  make \
  neomutt \
  ruby \
  vim

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

USER ${user}

ENV DEVDOTFILES_VIM_VER=1.6.4
RUN mkdir -p /home/${user}/opt \
  && cd /home/${user}/opt \
  && curl -fsSL https://github.com/skopciewski/dotfiles_vim/archive/${DEVDOTFILES_VIM_VER}.tar.gz | tar xz \
  && cd dotfiles_vim-${DEVDOTFILES_VIM_VER} \
  && make

# mutt config
COPY --chown=${user}:${user} data/mutt /home/${user}/.mutt
RUN ln -sf ${MUTT_MAILS_DIR} /home/${user}/.mails \
  && ln -sf ${MUTT_ABOOK_DIR} /home/${user}/.abook

ENTRYPOINT ["/entrypoint"]
CMD ["all"]
