const limine = @import("limine.zig");

pub export var limine_base_revision: limine.BaseRevision = .{ .revision = 0 };
pub export var framebuffer_request: limine.FramebufferRequest = .{};

// the fun stuff
// goals:
//   full support for the zig standard library

const std = @import("std");
const Terminal = @import("Terminal.zig");

// TODO : this shit keeps crashing on boot, there has to be an easier way,
// maybe go back to the old manual way just with a few new things
// from what we know in limine.zig
export fn main() noreturn {
    if (framebuffer_request.response == null) {
        while(true){}
    }
    const fb_response: *limine.FramebufferResponse = framebuffer_request.response.?;

    const fb: *limine.Framebuffer = fb_response.framebuffers.?[0];
    const raw_addr = fb.address;
    const width = @as(usize, fb.width);
    const height = @as(usize, fb.height);
    const pitch = @as(usize, fb.pitch);

    var term = Terminal.init(.{
        .ptr = @alignCast(@ptrCast(raw_addr)),
        .width = width,
        .height = height,
        .pitch = pitch,
    });

    term.clear(Terminal.color(20, 30, 40, 255));
    term.fg = Terminal.color(255, 255, 255, 255);

    term.print("BlinkOS 64-bit Core Online.\n");
    term.print("PSF2 Font Engine Rendered Successfully via Graphics Framebuffer!\n");

    while (true) {}
}

test "blos" {
    _ = Terminal;
}
