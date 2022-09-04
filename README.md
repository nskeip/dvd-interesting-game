# dvd-interesting-game

A simple (automatically played ^_^) game build via Raylib.

To build a web version, run:
```bash
mkdir build
cd build
emcc -o dvd.html ../main.c -Os -Wall /path/to/raylib/src/libraylib.a -I. \
 -I/path/to/raylib/src/ -L. -L/path/to/raylib/src/libraylib.a -s USE_GLFW=3 \
 --preload-file ../resources@./resources --shell-file ../shell.html -DPLATFORM_WEB
```
