
AS=kickass

hello.prg: hello.asm rasterbar.asm
	$(AS) hello.asm

run: hello.prg
	x64 hello.prg

