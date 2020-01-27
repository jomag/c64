
// This macro waits for the raster to be at line zero.
// The raster is 9 bits: 8 bits in $d012 and the MSB
// is bit 7 of $d011. The BIT operation will set negative
// flag depending on bit 7 in the value it compares, so we
// can use BPL to loop until bit 7 of $d011 has been set.
// We then wait until it becomes zero again, meaning we
// are on the first line.
.macro WaitForRasterZero() {
waitUntilSet:
        bit $d011
        bpl waitUntilSet
waitUntilCleared:
        bit $d011
        bmi waitUntilCleared
}