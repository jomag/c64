BasicUpstart2(start)
* = $4000 "Main Program"

posY: .byte $7a

barIndex: .byte 0

colors:         .fill 100, 0

blueBar:
        .byte 6,4,10,1,1,10,4,6
        .byte 5, 13, 3, 1, 1, 3, 13, 5
        .byte 6, 14, 3, 1, 1, 3, 14, 6
        .byte 9, 2, 8, 7, 7, 8, 2, 9

sine:
        .fill 256, 127.5 + 30*sin(toRadians(i*2*360/256)) // Generates a sine curve

barSine: .fill 256, 50 + 30 * sin(toRadians(i*2*360/256))

iter1: .byte 0

start:  
/////////////////////////

         sei              // disable interrupts

         lda #$00         // load $00 into A
         sta $d011        // turn off screen. (now you have only borders!)
         sta $d020        // make border black.

main:   
        // Wait until we are at line 0
        ldy #0
        cpy $d012
        bne main
        cpy $d011
        bne main

        ///////////////////////////////////////////////
        /// Generate the color buffer from the sine bars
        ///////////////////////////////////////////////

        // Clear color buffer
        ldx #99
        lda #0
!loop:  sta colors,x
        dex
        bne !loop-

        // Benchmark
        lda #12
        sta $d020

        lda #0
        sta iter1
        inc barIndex

renderBars:
        lda barIndex
        adc iter1
        adc iter1
        adc iter1
        adc iter1
        adc iter1
        adc iter1
        adc iter1
        adc iter1
        tay
        lda barSine,y
        tay

        // Choose offset in source bitmap
        // based on first bit of the bar number
        lda iter1
        and #3
        asl
        asl
        asl
        tax

!loop:  
        lda blueBar,x
        sta colors,y
        iny
        inx

        txa
        and #7
        bne !loop-

        inc iter1
        lda iter1
        cmp #5
        bne renderBars

        lda posY
        adc #1
        // and #127
        sta posY
        tay

        lda sine,y
        tay
        ldy #$37

        ldx #0          // load $00 into X

        // Benchmark
        lda #0
        sta $d020


loop:   lda colors,x    // load value at label 'colors' plus x into a. if we don't add x, only the first 
                        // value from our color-table will be read.

        cpy $d012      // ComPare current value in Y with the current rasterposition.
        bne *-3        // is the value of Y not equal to current rasterposition? then jump back 3 bytes (to cpy).

        sta $d020      // if it IS equal, store the current value of A (a color of our rasterbar)
                        // into the bordercolour

        cpx #99        // compare X to #51 (decimal). have we had all lines of our bar yet?
        bne !+         // Branch if EQual. if yes, jump to main.
        jmp main
!:
        inx              // increase X. so now we're gonna read the next color out of the table.
        iny              // increase Y. go to the next rasterline.

        jmp loop         // jump to loop.


////////////////////////////////////






        jsr initScreen
        jsr colorBars
theEnd: jmp theEnd

//// Subroutine: display color bars ("raster bars") forever!

colorBars:

x1:
        lda $d012
        cmp #$40
        bcc x1

        lda $0
        sta $d020
        sta $d021

x2:
        lda $d012
        cmp #$42
        bcc x2

        lda $3
        sta $d020
        sta $d021

        jmp x1


trick:
        lda $d012
        cmp #$30
        bpl notBeforeBar

        lda 0
        sta $d020
        sta $d021
        jmp trick

notBeforeBar:
        cmp #$40
        bpl afterBar

        lda 1
        sta $d020
        sta $d021
        jmp trick

afterBar:
        lda 0
        sta $d020
        sta $d021
        jmp trick


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
        tax
        lda #$20

clearScreenLoop:
        // Clear the screen memory (0x400 - 0x7FF)
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        dex
        bne clearScreenLoop
        rts

