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

        lda #$00         // load $00 into A
        sta $d011        // turn off screen. (now you have only borders!)

        jsr initScreen

        jsr prepareRasterBars

        // STABLE RASTER EXPERIMENT
        lda #<WedgeIRQ
        sta $fffe
        lda #>WedgeIRQ
        sta $ffff

        // Set the Raster IRQ to trigger on the next Raster line
        lda #80
        sta $d012
//        inc $d012

        // Acknowlege current Raster IRQ
        lda #$01
        sta $d019

        // Store current Stack Pointer (will be messed up when the next IRQ occurs)
        tsx

        // Allow IRQ to happen (Remeber the Interupt flag is set by the Interrupt Handler).
        cli

        // Execute NOPs untill the raster line changes and the Raster IRQ triggers
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        // Add one extra nop for 65 cycle NTSC machines
        // CYCLECOUNT: [64 -> 71]

WedgeIRQ:
        // At this point the next Raster Compare IRQ has triggered and the jitter is max 1 cycle.
        // CYCLECOUNT: [7 -> 8] (7 cycles for the interrupt handler + [0 -> 1] cycle Jitter for the NOP)

        // Restore previous Stack Pointer (ignore the last Stack Manipulation by the IRQ)
        txs

        // PAL-63  // NTSC-64    // NTSC-65
        //---------//------------//-----------
        ldx #$08   // ldx #$08   // ldx #$09
        dex        // dex        // dex
        bne *-1    // bne *-1    // bne *-1
        bit $00    // nop        // nop

        // Check if $d012 is incremented and rectify with an aditional cycle if neccessary
        lda $d012
        cmp $d012  // <- critical instruction (ZERO-Flag will indicate if Jitter = 0 or 1)

        // CYCLECOUNT: [61 -> 62] <- Will not work if this timing is wrong

        // cmp $d012 is originally a 5 cycle instruction but due to piplining tech. the
        // 5th cycle responsible for calculating the result is executed simultaniously
        // with the next OP fetch cycle (first cycle of beq *+2).

        // Add one cycle if $d012 wasn't incremented (Jitter / ZERO-Flag = 0)
        beq *+2

        // Stable code
        lda #GREEN
        sta $d020
        sta $d021
        lda #BLACK
        sta $d020
        sta $d021
        //jsr renderRasterBars

main:
        jmp main




xmain:   WaitForRasterZero()
        jsr renderRasterBars
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
