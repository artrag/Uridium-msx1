


                        M.A.Z.E  2KBOS
              
                     (c) 2008 dvik&joyrex
            
            
            
            
INTRODUCTION
============

M.A.Z.E 2KBOS is a game developed for Concurso 2Kb Opensource 2008.

The objective of the game is to guide mr. Penguin to the opening in
outer wall of the maze within the time limit. When mr Penguin moves
to a new square in the maze, you're awarded with one point, but you
get the real payoff is when you reach the opening and you get bonus
points based on the time left.


CONTROLS
========

You can use either the cursor keys of the keyboard or a joystick.
It can sometimes be tricky to get into a new corridor in the maze
but by aiming diagonal, e.g. up/right, you have a better chance
to quickly get where you want.


LOADING
=======

The game can be loaded from disk or from tape. With the game on
your medium of choise, type

    BLOAD"MAZE.BIN",R
    
    
SYSTEM REQUIREMENTS
===================

M.A.Z.E is designed for european MSX1 machines with at least 16kB 
of RAM. The game runs on newer MSX systems and non european MSXes,
but the music may play faster and the palette may be different 
than intended.

Some MSXes may need to be booted with the CTRL key pressed in order
to reserve enough RAM. 


COMPILING
=========

The source code package comes with a Makefile but the source can be
compiled standalone as well. Compiling the game requires the following
tools from xl2s (www.xl2s.tk):

    sjasm   v0.39g
    pletter v0.4a

To compile it from a standard dos shell, type the following:

    sjasm.exe game.asm
    pletter.exe 0 game.bin
    sjasm.exe maze.asm
    
This produces the file MAZE.BIN which can be loaded on the MSX.
