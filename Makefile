
AS=kickass

hello.prg: hello.s
	$(AS) hello.s

run: hello.prg
	x64 hello.prg

