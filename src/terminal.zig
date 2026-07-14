const std = @import("std");
const psf = @import("terminal/psf.zig");
const header = psf.header;
const font_bytes = psf.bytes;

const FbInfo = struct {
    ptr: [*]volatile u32,
    width: usize,
    height: usize,
    pitch: usize,
};

var fb_ptr: [*]volatile u32 = undefined;
/// width of the frame buffer
var fb_width: usize = 0;
/// height of the frame buffer
var fb_height: usize = 0;
/// bytes per row of the frame buffer
var fb_pitch: usize = 0;
/// x position of the cursor
var cx: usize = 0;
/// y position of the cursor
var cy: usize = 0;
/// the forgroud color, in the format 0xAARRGGBB
var fg_color: Color = 0xFFFFFFFF;

pub const Color = u32;

/// pack rgba color values into an integer for the framebuffer
pub fn color(r: u8, g: u8, b: u8, a: u8) Color {
    return @as(u32, b) | @as(u32, g) << 8 | @as(u32, r) << 16 | @as(u32, a) << 24;
}

/// initialize the terminal and frame buffer
pub fn init(fb_info: FbInfo) void {
    fb_ptr = fb_info.ptr;
    fb_width = fb_info.width;
    fb_height = fb_info.height;
    fb_pitch = fb_info.pitch;
}

/// clear the terminal screen with the given color
pub fn clear(c: Color) void {
    cx = 0;
    cy = 0;
    const total_pixels = (fb_pitch / 4) * fb_height;
    for (0..total_pixels) |i| fb_ptr[i] = c;
}

pub fn fg(c: Color) void {
    fg_color = c;
}

/// write a char to the framebuffer
pub fn putChar(c: u8) void {
    if (c == '\n') {
        cx = 0;
        cy += header.height;
        return;
    }

    if (c >= header.numglyph) {
        return;
    }

    const g_start = header.headersize + (@as(usize, c) * header.bytesperglyph);
    const g_end = g_start + header.bytesperglyph;

    if (g_end > font_bytes.len) {
        return; 
    }

    if (g_start + header.bytesperglyph > font_bytes.len) {
        return;   
    }
    
    const g_data = font_bytes[g_start..g_end];
    const bytes_per_row = (header.width + 7) / 8;

    for (0..header.height) |y| for (0..header.width) |x| {
        const offset = (y * bytes_per_row) + (x / 8);
        const bit_offset = x % 8;
        const val = g_data[offset];

        if ((val & (@as(u8, 0x80) >> @intCast(bit_offset))) != 0) {
            const sx = cx + x;
            const sy = cy + y;

            if (sx < fb_width and sy < fb_height) {
                const pixels_per_row = fb_pitch / 4;
                const i = (sy * pixels_per_row) + sx;
                fb_ptr[i] = fg_color;
            }
        }
    };

    cx += header.width;
    if (cx + header.width >= fb_width) {
        cx = 0;
        cy += header.height;
    }
}

/// print a whole string to the terminal
pub fn print(s: []const u8) void {
    for (s) |c| putChar(c);
}

test "colors" {
    std.testing.expect(color(0, 0, 0, 255) == 0xFF000000);
    std.testing.expect(color(255, 0, 0, 0) == 0x00FF0000);
    std.testing.expect(color(0, 255, 0, 0) == 0x0000FF00);
    std.testing.expect(color(0, 0, 255, 0) == 0x000000FF);
}
