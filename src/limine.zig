//! code originally from: https://github.com/48cf/limine-zig
//!
//! since the above library uses now removed zig features, this file simply acts as a modern replacement

fn id(a: u64, b: u64) [4]u64 {
    return .{ 0xc7b1dd30df4c8b88, 0x0a82e883a194f07b, a, b };
}

pub const BaseRevision = extern struct {
    magic: [2]u64 = .{ 0xf9562b2d5c95a6c8, 0x6a7b384944536bdc },
    revision: u64,

    pub fn init(revision: u64) @This() {
        return .{ .revision = revision };
    }

    pub fn loadedRevision(self: @This()) u64 {
        return self.magic[1];
    }

    pub fn isValid(self: @This()) bool {
        return self.magic[1] != 0x6a7b384944536bdc;
    }

    pub fn isSupported(self: @This()) bool {
        return self.revision == 0;
    }
};

pub const FramebufferMemoryModel = enum(u8) {
    rgb = 1,
    _,
};

pub const VideoMode = packed struct {
    pitch: u64,
    width: u64,
    height: u64,
    bpp: u16,
    memory_model: FramebufferMemoryModel,
    red_mask_size: u8,
    red_mask_shift: u8,
    green_mask_size: u8,
    green_mask_shift: u8,
    blue_mask_size: u8,
    blue_mask_shift: u8,
};

pub const Framebuffer = extern struct {
    address: *anyopaque,
    width: u64,
    height: u64,
    pitch: u64,
    bpp: u16,
    memory_model: FramebufferMemoryModel,
    red_mask_size: u8,
    red_mask_shift: u8,
    green_mask_size: u8,
    green_mask_shift: u8,
    blue_mask_size: u8,
    blue_mask_shift: u8,
    edid_size: u64,
    edid: ?*anyopaque,
    mode_count: u64,
    modes: [*]*VideoMode,

    /// Helper function to retrieve the EDID data as a slice.
    /// This function will return null if the EDID size is 0 or if
    /// the EDID pointer is null.
    pub fn getEdid(self: @This()) ?[*]u8 {
        if (self.edid_size == 0 or self.edid == null) {
            return null;
        }
        return @as([*]u8, self.edid.?)[0..self.edid_size];
    }

    /// Helper function to retrieve a slice of the modes array.
    /// This function is only available since revision 1 of the response and
    /// will return an error if called with an older response. This is to
    /// prevent the user from possibly accessing uninitialized memory.
    pub fn getModes(self: @This(), response: *FramebufferResponse) ![]*VideoMode {
        if (response.revision < 1) {
            return error.NotSupported;
        }
        return self.modes[0..self.mode_count];
    }
};

pub const FramebufferResponse = extern struct {
    revision: u64,
    framebuffer_count: u64,
    framebuffers: ?[*]*Framebuffer,

    pub fn getFramebuffers(self: @This()) []*Framebuffer {
        if (self.framebuffer_count == 0 or self.framebuffers == null) {
            return &.{};
        }
        return self.framebuffers.?[0..self.framebuffer_count];
    }
};

pub const FramebufferRequest = extern struct {
    id: [4]u64 = id(0x9d5827dcd881dd75, 0xa3148604f6fab11b),
    revision: u64 = 1,
    response: ?*FramebufferResponse = null,
};
