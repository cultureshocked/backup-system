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


## License

Don't know yet. Don't use this software until I decide on one. :)


