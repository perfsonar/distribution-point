# Docker perfSONAR Repo Mirror

TODO: Write this.

## Prerequisites

This container requires the following:

 * Any `x86_64` system capable of running Docker or Podman

 * A directory on the host with enough space to hold whatever is being
   mirrored.  This directory is shared into the container and will be
   referred to as the "data directory" or `/data`.

 * A connection to the outside that allows inbound HTTPS (port 443)
   connections and outbound Rsync (port 873) connections.  If the
   container is to serve as a synchronization source, inbound Rsync
   (port 873) must be allowed as well.


## Configruration

The container's behavior is configured using files in `/data/config`.

Unless otherwise noted, these files are re-read regularly.


### Mirror Source List

The `mirror-sources` file contains a list of sites to be mirrored.  The
format of each line is two colums, separated by whitespace.  Comments
starting with `#` and empty lines are ignored.

Column 1 is the name of the web server subdirectory where the mirrored
directory will appear.  It is subject to these rules:

 * Subdirectories containing absolute paths or use of the parent
   directory (`..`) are ignored.

 * Subdirectories are not checked for uniqueness and synchronization
   will be done in the order specified.  Repeating a subdirectory will
   result in it being overwritten.

 * The current directory (`.`) is considered valid and will overwrite
   the root of the web server and any other subdirectories.  If used,
   this should be the only entry in the file.

Column 2 is an `rsync://` URL where the contents of can be mirrored.

Example file
```
foo    rsync://distro.example.edu/foo/
# This is disabled:
#bar   rsync://downloads.example.net/mirrors/bar/
baz    rsync://www.example.org/stuff/baz/
```

If this file does not exist, no synchronization will take place and
the contents of `/data/repo` will be served up as a static site.


### Rsync Host Authorization

The `rsync-hosts` file contains a list of IP addresses and CIDR blocks
that are allowed access via Rsync.

If this file is not present when the container starts, the Rsync
service will be disabled until it is restarted with it present.


### Web Server SSL

Place valid `key.pem` and `cert.pem` files in the configuration
directory to use SSL.  If both of these files are not present, the
container will generate self-signed filesand add them to the
configuration directory.


### Synchronization Interval

The `sync-interval` file contains an integer indicating the number of
seconds between each round of synchronization.

If this file is not present, a default of `10800` (three hours) will
be used.


### Message of the Day

The `motd` file, if present, contains a message that will be provided
to remote users of rsync.



## Running the Container

```
docker run \
    --volume /path/to/local/storage:/data:rw \
    --expose 443 \
    --expose 873
    TODO-image-name
```
