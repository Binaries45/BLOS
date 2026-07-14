/// a psf2 font header
const Header = extern struct {
    magic: u32,
    version: u32,
    headersize: u32,
    flags: u32,
    numglyph: u32,
    bytesperglyph: u32,
    height: u32,
    width: u32, 
};

/// the raw bytes of the font file
pub const bytes = @embedFile("../assets/zap-ext-light32.psftx");
/// a "parsed" font header
pub const header: *const Header = @alignCast(@ptrCast(bytes));

test "validate font" {
    @import("std").testing.expect(header.magic == 0x0);
}
