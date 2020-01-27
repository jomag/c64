# MoeCHIP-8 for C64

## C64 development

### File format: .prg

The .prg file format is very simple: the two first bytes contains an address
to where the rest of the file is to be loaded. It's common to use address
`$0801`, which is the default start address of the BASIC interpreter, and
start the file with a very small BASIC program that jumps to the machine
code program:

```basic
10 SYS 2304
```

## Colors

- 0: black
- 1: white
- 2: red
- 3: cyan
- 4: pink
- 5: green
- 6: blue
- 7: yellow
- 8: orange
- 9: brown
- 10: light red
- 11: dark gray
- 12: medium gray
- 13: light green
- 14: light blue
- 15: light gray

## Common registers

`$d012`: raster counter
`$d020`: border color
`$d021`: background color 1

## Resources

[Commodore 64 assembly coding on the command line](https://csl.name/post/c64-coding/)

[An Introduction to Programming C-64 Demos](http://www.antimon.org/code/Linus/) by Linus Åkerlund

[The MOS 6567/6569 video controller (VIC-II) and its application in the Commodore 64](http://www.zimmers.net/cbmpics/cbm/c64/vic-ii.txt?utm_source=share&utm_medium=ios_app&utm_name=iossmf)
