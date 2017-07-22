# zipstd

Zstandard compression in zip.


## Install

```sh
$ make test
$ INSTALL_DIR=[zipstd install directory] make install
```

## Usage

### Compression

```sh
Usage:
  zipstd [OPTIONS] files

Options:
  -h, --help
  -#: compression level, 1-19 (default: 3)
  -P, --processes NUMBER: Maximum number of processes (default: 1)
  -o FILENAME: output file (default: out.zip)
  -v: verbose mode
  -W: overwrite if output file already exists
  -x PATTERN:  no compress file pattern
```

### decompression

```sh
Usage:
  unzipstd [OPTIONS] files

Options:
  -h, --help
  -P, --processes ARG: Maximum number of processes (default: 1)
  -o ARG: output directory (default: .)
  -v: verbose mode
```

## License

MIT

