# backup-system

This project is a simple way for my computer to perform backups of important files.

Most of the code is designed to be portable across multiple systems, so long as they are running in a UNIX environment and have some tools available.

## Dependencies

`cryptopp` is assumed to be packaged inside the `src` directory.
The shell script makes heavy use of utilities such as `df`, `du`, `md5sum`, `sha256sum`, and `awk`. Most of these utilities should be installed on most linux systems by default.
Any C++ code will require the use of C++20, and your compiler is expected to support it.

## License

Don't know yet. Don't use this software until I decide on one. :)


