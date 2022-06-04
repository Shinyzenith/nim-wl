# Nim-WL:

Feel free to open github issues for any line of code that you do not understand. This is a repo made to teach people to learn how to write wayland compositors in nim.

NOTE: This project is a WIP.

# Acknowledgement:
Thank you <a target="_blank" href="https://github.com/pmunch">PMunch</a> and <a target="_blank" href="https://github.com/beef331">ElegantBeef</a> for addressing my stupid newbie questions regarding futhark.

# Building:

## Dependencies:
1. Clang
1. Nim
1. Nimble

```bash
git clone https://github.com/waycrate/nim-wl
cd nim-wl
make
./herb
```

If you get errors regarding clang path, change the path to clang include directory in `libherb.nim`.
