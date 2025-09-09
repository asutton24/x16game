# Octathlon

A Platformer for the Commander X16

## Build Instructions

Download and build the [assembler](https://github.com/asutton24/6502assembler)

If the assembler executable is in the working directory, simply run `./assemble -x` to build the program file

## Running the Game

To run the game, copy SPR0.BIN, all STGX.BIN files, and a.bin to the Commander X16 emulator directory (Or to a directory on the SD card, if on real hardware)

Navigate to the directory on the X16, enter `LOAD "A.BIN"` and `RUN` to begin

## Instructions

Octathlon is played on the keyboard

Arrow keys to move

Z to jump

X to shoot

You play as a robot in a very low resolution enviornment full of equally simple enemies. On each screen you have one goal, to reach the door before the 8-second timer expires.

There are 40 screens across 4 stages. Simply try to get to the end, or play for score by dying/restarting as few times as possible!
