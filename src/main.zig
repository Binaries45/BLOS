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
    _ = trace;
    _ = sz;

    terminal.fg(@intFromEnum(terminal.Colors.Red));
    terminal.print(msg);
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

    terminal.clear(@intFromEnum(terminal.Colors.Black));
    terminal.fg(@intFromEnum(terminal.Colors.White));
    
    // TODO :
    //   print init info
    terminal.print("[init]\n");
    
    //   print logo
    terminal.printf("{s}\n", .{art.LOGO});
    
    //   print pc specs
    //   print color palette

    // start of logo & info
    terminal.printf("   \n", .{});
    terminal.printf("   OS: {s}\n", .{"todo"});
    terminal.printf("   CPU: {s}\n", .{"todo"});
    terminal.printf("   GPU: {s}\n", .{"todo"});
    terminal.printf("   Memory: {s}\n", .{"todo"});
    terminal.printf("   \n", .{});
    terminal.printf("   \n", .{});
    terminal.printf("   \n", .{});
    terminal.printf("   \n", .{});
    terminal.printf("   \n", .{});
    terminal.printf("   \n", .{});
    terminal.printf("   \n", .{});
    terminal.printf("   \n", .{});
    terminal.printf("   \n", .{});
    terminal.printf("   \n", .{});
    terminal.printf("   \n", .{});
    // end of logo & info
    
    // the above two will print with specs above colors, and both next to the logo
    asm volatile ("sti");

    // TODO : after this point the user should be able to use their keyboard and mouse in the terminal,
    // ideally once in this section they can use commands, and mess around with stuff.

    while (true) {}
}

test "blos" {
    std.builtin.CallingConvention;
    _ = terminal;
}
