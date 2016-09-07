# Mutt docker container

## Usage

The container provides the mutt instance for managing mounted mailbox. Accounts configuration is generated from mayaml.yml file (see: [Mayaml project][mayaml_url]).

```bash
  docker run -it --rm --name mailgrabber \
    -v /path/to/mayaml.yml:/mnt/mayaml.yml \
    -v /path/to/maildir:/mnt/mails \
    -v /path/to/abook:/mnt/abook \
    skopciewski/mutt
```

### Escape to

If you want to execute other command than `mutt`, run docker container with `escto` as first param:

```bash
  docker run -it --rm --name mailgrabber \
    -v /path/to/mayaml.yml:/mnt/mayaml.yml \
    -v /path/to/maildir:/mnt/mails \
    -v /path/to/abook:/mnt/abook \
    skopciewski/mutt escto bash
```

## Dependencies and requirements

* `mayaml.yml` file mounted to the `$MAYAML_FILE` (default: `/mnt/mayaml.yml`)
* local maildir mounted to the `$MUTT_MAILS_DIR` (default: `/mnt/mails`)
* local abook dir mounted to the `$MUTT_ABOOK_DIR` (default: `/mnt/abook`)

Additionally:

* set the owner of created files by overwriting `$MUTT_USER_ID` (default: `1000`) and `$MUTT_GROUP_ID` (default: `1000`)

[mayaml_url]: https://github.com/skopciewski/mayaml
