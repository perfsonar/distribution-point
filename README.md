# Distribution Point

This Docker container establishes a web and, optionally, an rsync
server for use in distributing perfSONAR and other things.

## Prerequisites

This container requires the following:

 * Any `x86_64` system capable of running Docker or Podman

 * A directory on the host with enough space to hold whatever is being
   mirrored.  This directory is shared into the container and will be
   referred to as the _data directory_ or `/data`.  The
   currently-recommended size for mirroring perfSONAR is 100 GB.

 * A connection to the outside that allows these connections:

   * Inbound HTTPS (TCP port 443)
   * Outbound rsync (TCP port 873)
   * Inbound rsync (TCP port 873) if the server is to provide rsync
     service to other servers.


## Configruration

The container's behavior is configured using files in the
`/data/config` subdirectory.

All configuration is re-read and re-applied on a regular basis.


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

Column 2 is an `rsync://` URL pointing to the source of what is to be
mirrored.

Example file:
```
foo    rsync://distro.example.edu/foo/
bar    rsync://www.example.org/stuff/bar/
```

If this file does not exist, no synchronization will take place and
the contents of `/data/repo` will be served as-is.

This file is re-read at the beginning of each synchronization cycle.


### Synchronization Interval

The `sync-interval` file contains an integer indicating the number of
seconds between the completion of one synchronization cycle and the
next.  If it is not present, a default of `10800` (three hours) will
be used.

This file is re-read at the conclusion of each synchronization cycle.


### Rsync Host Authorization

The `rsync-hosts` file contains a list of hosts, one per line, that
will be allowed to connect to the rsync daemon.  Valid entry are all
those listed in the rsync daemon's [allowed hosts
format](https://download.samba.org/pub/rsync/rsyncd.conf.5#hosts_allow)
except `@netgroup`, as no netgroups are provided in the container.

This file is checked for changes once per minute and rsyncd is
restarted if it differs.


### Web Server SSL

Place valid `key.pem` and `cert.pem` files in the configuration
directory to use SSL.  If both of these files are not present, the
container will generate self-signed files and add them to the
configuration directory.

These files are read once when the container starts.


### Message of the Day

The `motd` file, if present, contains a message that will be provided
to remote users of rsync and when the web server generates a directory
listing.



## Running the Container

```
docker run \
    --volume /path/to/local/storage:/data:Z \
    --expose 443 \
    --expose 873 \
    ghcr.io/perfsonar/distribution-point:latest
```

Note that ports `443` and `873` must be exposed manually so only the
desired services are shown to the outside.


## Developer Notes

The `Makefile` at the top level of the source tree contains these
targets for convenience:

 * `build` - Builds a test container image.

 * `run` - Builds a copy of the `sample-data` directory in `/tmp` and
   Creates and runs a test container until stopped with a `SIGINT` or
   `Ctrl-C`.  This is the default target.

 * `shell` - Runs an interactiveshell inside the test container.

 * `halt` - Stops the test container.

 * `rm` - Removes the test container and images from Docker.

 * `clean` - Removes the test container and images from Docker and all
   by-products of the `build` and `run` targets.
