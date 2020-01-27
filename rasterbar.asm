.const PATH_LENGTH = 256
.const HEIGHT = 64
.const BAR_HEIGHT = 8
.const TOP = 80
.const BACKGROUND = BLACK

barCount:
        .byte 5

barDistance:
        .byte 13

barColors:
        .byte 6, 4, 10, 1, 1, 10, 4, 6
        .byte 5, 13, 3, 1, 1, 3, 13, 5
        .byte 6, 14, 3, 1, 1, 3, 14, 6
        .byte 9, 2, 8, 7, 7, 8, 2, 9

barPath:
        .fill PATH_LENGTH, HEIGHT / 2 - BAR_HEIGHT / 2 + ((HEIGHT - BAR_HEIGHT) / 2) * sin(toRadians(i * 360 / PATH_LENGTH))

rasterBarsTop:
        .byte TOP

rasterBarsPathIndex:
        .byte 0

buffer:
        .fill HEIGHT+1, 0

prepareRasterBars:
        // Clear buffer
        ldx #HEIGHT
        lda #BACKGROUND
!:      dex 
        sta buffer,x
        bne !-

        // Increment frame index
        lda rasterBarsPathIndex
        adc #1
        and #PATH_LENGTH-1
        sta rasterBarsPathIndex

        // Iterate all bars to be displayed
        lda #0
        sta zp0         // Use zp0 as iterator

        lda rasterBarsPathIndex
        sta zp1         // Use zp1 for bar path separation

renderBarsLoop:
        // Get Y offset of current bar
        ldy zp1
        lda barPath,y
        tay

        // Select source bitmap (4 available, each 8 byte long)
        lda zp0
        and #3
        asl
        asl
        asl
        tax

!:      // Transfer the 8 color values from source to buffer
        lda barColors,x
        sta buffer,y
        iny
        inx

        txa
        and #7
        bne !-

        // Set zp1 to path index of next bar
        lda zp1
        adc barDistance
        sta zp1

        // Render next bar, or return if all have been rendered
        inc zp0
        lda zp0
        cmp barCount
        bne renderBarsLoop
        rts

renderRasterBars:
        ldy rasterBarsTop
        ldx #0

lineLoop:
        lda buffer,x

        // Wait until raster is at start of the next line
!:      cpy $d012
        bne !-

        // Set border color to current color
        sta $d020
        sta $d021

        // If this was the last line, return from subroutine
        cpx #HEIGHT
        bne !+
        lda #$0
        sta $d020
        sta $d021
        rts

!:      inx             // Increment buffer offset
        iny             // Increment raster line
        jmp lineLoop
