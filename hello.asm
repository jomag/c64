BasicUpstart2(start)

* = $10 virtual
.zp {
        zp0: .byte 0
        zp1: .byte 1
        zp2: .byte 2
        zp3: .byte 3
}

* = $4000 "Main Program"
#import "macros.asm"
#import "rasterbar.asm"

sine:   .fill 256, 127.5 + 30*sin(toRadians(i*2*360/256)) // Generates a sine curve

start:  sei

        // lda #$00         // load $00 into A
        // sta $d011        // turn off screen. (now you have only borders!)

        jsr initScreen
        jsr prepareRasterBars

main:   WaitForRasterZero()
        jsr renderRasterBars
        jsr prepareRasterBars
        jmp main

/// Subroutine: initScreen - init and clear screen
initScreen:
        // Set border and background color to black (color 0)
        lda #$00
        sta $d020
        sta $d021

clearScreen:
        // Put value of acc in reg X and set acc
        // to the character we want to clear the
        // screen memory with ($20 = space)
        lda #0
        tax
        lda #$20

!:      // Clear the screen memory (0x400 - 0x7FF)
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        dex
        bne !-
        rts
