# backup-system

This project is a simple way for my computer to perform backups of important files.

Most of the code is designed to be portable across multiple systems, so long as they are running in a UNIX environment and have some tools available.

## Dependencies

`cryptopp` is assumed to be packaged inside the `src` directory. Installation guide follows.

The shell script makes heavy use of utilities expected to be installed on your system. Many of these will be installed by default on most systems. Notably, the list includes:

- `md5sum`
- `sha256sum`
- `lsblk`
- `awk`
- `7z`
- `bash` (use of `readarray` makes this script incompatible with `zsh` or other shells)

## Building the validator

The validator effectively reads the hashes generated at archival time from a store (by default `/path/to/backups/directory/integrity.txt`), recalculates the hashes of all the archives in the directory, and compares each stored hash against the recalculated one.

The logic is fairly simple and the program is probably close to ~100 lines. However, it outsources all cryptographic operations to `CryptoPP`, a widely used cryptographic library for C++.

I personally do not feel comfortable writing my own implementations of cryptographic functions, but I also do not feel comfortable requiring a pre-built distribution for cryptographic functions. As such, I have opted to build `libcryptopp` from source and statically link it in the makefile.

To make the `Makefile` work out of the box for your system, follow these steps (or if your system doesn't have the same utilities as mine, perform the steps with whatever utilities you have access to.)

```sh
git clone https://github.com/cultureshocked/backup-system   # clone this repository
cd backup-system/src/validation                             # navigate to the validator directory
wget https://www.cryptopp.com/cryptopp890.zip               # download cryptopp latest, update vesion as needed

# optional but highly recommended: verify sha256 of the archive you downloaded
# remember to adjust the checksum from the website and verify that I am telling the truth here
# cryptopp site with hashes + download links: https://www.cryptopp.com/downloads.html
echo "4cc0ccc324625b80b695fcd3dee63a66f1a460d3e51b71640cdbfc4cd1a3779c cryptopp890.zip" | sha256sum --check

mkdir cryptopp
unzip cryptopp890.zip -d cryptopp

# optional: cleanup archive once extracted
rm cryptopp890.zip

cd cryptopp
make
```

These steps will build `libcryptopp.a` in the `cryptopp` directory, which is then linked in the `Makefile` for the validator. All the headers will be available in `./cryptopp/` as well, so `main.cpp` can correctly `#include` them.

To finish installing, move the generated binary (`main`) to the root of your backups folder. Rename it to `verify`.

I know this process is really weird and clunky. It'll get better at some point. I want all the moving parts to work on their own before I streamline the build/install process. This project is far from finished.


## Building the pruner

```sh
# ... from the repository root...
cd src/pruner
g++ -std=c++20 main.cpp -o prune
```

Move the binary (`prune`) to the root of your backup root folder.


## Rough directory structure explanation

This system will backup files and folders, based on a whitelist that you provide, to some sort of hot-media, in my case, a flash drive. It detects your flash drive based on its serial number.

Right now, the serial number is hardcoded to `backup.sh` and if you want this system to work for you, you will need to change it.

This is how I get the serial number if you know the device name (e.g., `/dev/sda`) (it is not the only way):
```sh
lsblk -o name,serial | awk '/[DEVICE NAME]/ { print $NF }'
```
Replacing the `[DEVICE NAME]` as needed.

You can put `backup.sh`, `generate_paths.sh`, and create a new file called `directories_to_backup.txt` in the same folder somewhere on your system. You can also rename the whitelist file to something else, just be sure to reflect the changed name near the top of `backup.sh`.

The hot media will be mounted by the script if it is not already mounted. By default, it will be mounted to `/mnt/backup`, and the folder will be created if it doesn't already exist.

Inside the hot-media, the script will assume that `/mnt/backup/backup-daily` is the root of the archival folder. This is where you want to put the two binaries, `prune` and `verify`.

Here's a simple tree-like diagram:
```
hot_media_root
 ┗━ backup-daily
     ┣━ integrity.txt       # made automatically during backup execution
     ┣━ verify
     ┣━ prune 
     ┗━ [archive.7z files]

/path/to/scripts
 ┣━ backup.sh 
 ┣━ generate_paths.sh 
 ┗━ directories_to_backup.txt
```

Most of these paths and filenames are customizable within the first few lines of `backup.sh`.

There are no checks to see if files exist, except in the `prune` and `verify` binaries. If something goes wrong, there's a very good chance that you just mistyped a filename or path somewhere.


## License

Don't know yet. Don't use this software until I decide on one. :)

Seriously, you might brick something. At least let me streamline a couple parts first.
