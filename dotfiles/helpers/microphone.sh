#!/usr/bin/env bash


# Doc: Records the input for 1 minute and plays it automatically.
function mictest() {
    arecord -f S16_LE -d 60 -r 16000 -B 1 | aplay
}
