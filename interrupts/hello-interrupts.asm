// This is a very simple program showing how to use
// interrupts. It will cause an interrupt to occur on
// raster line 100, and the interrupt handler will change
// the background color to yellow. The interrupt handler
// will also be replaced by another one which is triggered
// at raster line 160. The second interrupt handler will
// return the background color to black and restore the
// initial interrupt handler.

BasicUpstart2(start)

* = $4000 "Main Program"

start:
        // Disable interrupts
        sei

        // By default, the CIA interrupts are enabled.
        // Each type of CIA interrupt has a matching
        // bit in $dc0d and we should disable them all.
        lda #%01111111
        sta $dc0d

        // Bit 7 in $d011 is the raster compare enable
        // bit. When enabled, a raster compare interrupt
        // will occur when the raster counter matches
        // the value of $d012
        lda #%01111111
        and $d011
        sta $d011

        // Set $d012 to trigger an interrupt on line
        // 100
        lda #100
        sta $d012

        // $0314 and $0315 holds the low and high bits
        // of the address to the irq interrupt handler
        lda #<interrupt_handler1
        sta $0314
        lda #>interrupt_handler1
        sta $0315

        // Finally, enable raster interrupts, bit 1
        // in $d01a.
        lda #%00000001
        sta $d01a

        // Enable interrupts
        cli

        // An alternative at this point would be to
        // return to BASIC using rts:
        rts

        // If we're still here, enter endless loop
loop:   jmp loop

interrupt_handler1:
        // Set border color to yellow to indicate
        // that this was where the interrupt occured
        lda #YELLOW
        sta $d020
        sta $d021

        // Switch to second interrupt handler and change
        // the raster compare register to line 120
        lda #160
        sta $d012
        lda #<interrupt_handler2
        sta $0314
        lda #>interrupt_handler2
        sta $0315

        // Acknowledge the interrupt. If not the interrupt
        // handler will be retriggered until it is acked.
        asl $d019

        // Jump to the default kernal interrupt handler
        jmp $ea31

interrupt_handler2:
        // This second handler works the same as the
        // first one, except the raster compare and color
        // used has changed. It also restores interrupt_handler
        // as interrupt handler.
        lda #BLACK
        sta $d020
        sta $d021

        lda #100
        sta $d012

        lda #<interrupt_handler1
        sta $0314
        lda #>interrupt_handler1
        sta $0315

        asl $d019
        jmp $ea31
