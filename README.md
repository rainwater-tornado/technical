# Rainwater Tornado Technical Resources

[Rainwater Tornado](https://rainwatertornado.cloud/) operates a server for seeding BitTorrent torrents. This repository contains various notes and resources for those interested in starting a similar project.

## BitTorrent Client

The server is a Linux system running the [Transmission](https://transmissionbt.com/) daemon (`transmission-daemon` package in Debian).

Transmission will automatically seed existing data obtained from outside sources. All you need to do is place the files in the download directory and add the torrent. Transmission will verify that the data is correct and start seeding it.

The configuration file for Transmission that Rainwater Tornado uses can be found in `etc/transmission-daemon/settings.json`. You may adapt this for your own purposes; more information is available on [Transmission's GitHub wiki](https://github.com/transmission/transmission/wiki/Editing-Configuration-Files). (Security note: The configuration file allows remote-control access from localhost only and without any authentication. You should consider if this is suitable for your application.)

The `transmission-remote` program is used to manage the torrents in the daemon (add, remove, start, stop, etc.). Common commands include:

* `transmission-remote -a [file/magnet]`: Add a torrent (Note: Only one torrent is supported for this command, despite what the man page may suggest)
* `transmission-remote -l`: List torrents
* `transmission-remote -t [torrent number(s)] -s`: Start seeding/downloading torrent(s) (numbers are the ones found in the output of `-l`; multiple numbers can be specified with commas and hyphens as in `-t 2,4,6-8` for 2, 4, 6, 7, and 8)
* `transmission-remote -t [torrent number(s)] -S`: Stop seeding/downloading torrent(s)
* `transmission-remote -t [torrent number(s)] -r`: Remove torrents (while keeping data)
* `transmission-remote -t [torrent number(s)] -rad`: Remove torrents and delete data

## Deduplication

A simple deduplication system ensures that only a single copy of a file is stored even when it appears in multiple torrents.

This system consists of a special "dedup" directory that contains files named by their hashes. Currently, the hash algorithm is SHA-256, and there are subdirectories for the first four hex digits. (For example, the empty file would be stored at `dedup/e3b0/c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.) The actual download directory for the BitTorrent client contains symbolic links to the files in the dedup directory.

The script in `opt/rainwatertornado/dedup.sh` adds/finds a file in the dedup directory and replaces the original with a symbolic link. Refer to the comments in the script for more information.

## License

The contents of this repository are dedicated to the public domain under [Creative Commons CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/). A copy is available in `LICENSE.txt`.