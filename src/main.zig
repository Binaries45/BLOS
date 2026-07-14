const limine = @import("limine.zig");

pub export var limine_base_revision: limine.BaseRevision = .{ .revision = 0 };
pub export var framebuffer_request: limine.FramebufferRequest = .{};

// the fun stuff
// goals:
//   full support for the zig standard library

const std = @import("std");
const terminal = @import("Terminal.zig");
const art = @import("art.zig");

pub fn panic(msg: []const u8, trace: ?*std.builtin.StackTrace, sz: ?usize) noreturn {
    _ = msg;
    _ = trace;
    _ = sz;

    terminal.clear(terminal.color(255, 0, 0, 255));
    while (true) {}
}

export fn main() noreturn {
    asm volatile ("cli");
    if (framebuffer_request.response == null) {
        while(true){}
    }
    const fb_response: *limine.FramebufferResponse = framebuffer_request.response.?;

    const fb: *limine.Framebuffer = fb_response.framebuffers.?[0];
    const raw_addr = fb.address;
    const width = @as(usize, fb.width);
    const height = @as(usize, fb.height);
    const pitch = @as(usize, fb.pitch);

    terminal.init(.{
        .ptr = @alignCast(@ptrCast(raw_addr)),
        .width = width,
        .height = height,
        .pitch = pitch,
    });

    terminal.clear(terminal.color(0, 0, 0, 255));
    terminal.fg(terminal.color(255, 255, 255, 255));

    terminal.print("boot successful\n");
    terminal.print(art.LOGO);
    asm volatile ("sti");

    while (true) {}
}

test "blos" {
    _ = terminal;
}
