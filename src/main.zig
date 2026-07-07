// multiboot header nonsense
const MAGIC: u32 = 0xe85250d6;
const ARCH : u32 = 0;
const LEN  : u32 = @sizeOf(Multiboot2Header);

const Multiboot2Header = extern struct {
    magic: u32 = MAGIC,
    architecture: u32 = ARCH,
    header_length: u32 = LEN,
    checksum: u32,
    
    end_tag_type: u16 = 0,
    end_tag_flags: u16 = 0,
    end_tag_size: u32 = 8,
};

const magic_sum = MAGIC + ARCH + @as(u32, LEN);
const calculated_checksum = ~magic_sum +% 1;

export const multiboot_header: Multiboot2Header align(8) linksection(".multiboot") = .{
    .checksum = calculated_checksum,
};

// the fun stuff
export fn main() noreturn {
    while (true) {}
}
