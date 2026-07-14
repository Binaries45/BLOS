
const std = @import("std");

pub fn build(b: *std.Build) void {
    var disabled = std.Target.Cpu.Feature.Set.empty;
    var enabled  = std.Target.Cpu.Feature.Set.empty;
    
    disabled.addFeature(@intFromEnum(std.Target.x86.Feature.mmx));
    disabled.addFeature(@intFromEnum(std.Target.x86.Feature.sse));
    disabled.addFeature(@intFromEnum(std.Target.x86.Feature.sse2));
    disabled.addFeature(@intFromEnum(std.Target.x86.Feature.sse3));
    disabled.addFeature(@intFromEnum(std.Target.x86.Feature.ssse3));
    disabled.addFeature(@intFromEnum(std.Target.x86.Feature.sse4_1));
    disabled.addFeature(@intFromEnum(std.Target.x86.Feature.sse4_2));
    disabled.addFeature(@intFromEnum(std.Target.x86.Feature.avx));
    disabled.addFeature(@intFromEnum(std.Target.x86.Feature.avx2));
        
    enabled.addFeature(@intFromEnum(std.Target.x86.Feature.soft_float));
    
    const target = std.Target.Query {
        .cpu_arch = .x86_64,
        .os_tag = .freestanding,
        .abi = .none,
        .cpu_features_add = enabled,
        .cpu_features_sub = disabled,
    };

    const optimize = b.standardOptimizeOption(.{});

    const limine = b.dependency("limine_zig", .{
        .api_revision = 3,
        .allow_deprecated = false,
        .no_pointers = false,
    });
    const limine_mod = limine.module("limine");

    const kernel = b.addExecutable(.{
        .name = "BlinkOS.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = b.resolveTargetQuery(target),
            .optimize = optimize,
            .code_model = .kernel,
        }),
        .use_llvm = true,
    });

    kernel.pie = false;
    kernel.root_module.addImport("limine", limine_mod);
    kernel.setLinkerScript(b.path("linker-x86_64.ld"));
    kernel.root_module.addAssemblyFile(b.path("src/asm/entry.s"));

    b.installArtifact(kernel);

    
    const iso_root = b.addWriteFiles();
    _ = iso_root.addCopyFile(kernel.getEmittedBin(), "BlinkOS.elf");
    _ = iso_root.addCopyFile(b.path("limine/limine-bios.sys"), "limine-bios.sys");
    _ = iso_root.addCopyFile(b.path("limine/limine-bios-cd.bin"), "limine-bios-cd.bin");
    _ = iso_root.addCopyFile(b.path("limine/limine.conf"), "limine.conf");

    const xorriso = b.addSystemCommand(&.{
        "xorriso",
        "-as", "mkisofs",
        "-b", "limine-bios-cd.bin",
        "-no-emul-boot",
        "-boot-load-size", "4",
        "-boot-info-table", 
    });

    xorriso.addDirectoryArg(iso_root.getDirectory());
    xorriso.addArg("-o");
    const iso_out = xorriso.addOutputFileArg("bin/BlinkOS.iso");
    const install_iso = b.addInstallFile(iso_out, "bin/BlinkOS.iso");

    const make_iso_step = b.step("make-iso", "make an ISO image of the OS");
    make_iso_step.dependOn(&install_iso.step);

    const run_cmd = b.addSystemCommand(&.{
        "qemu-system-x86_64",
        "-cdrom"
    });
    
    run_cmd.addFileArg(iso_out); 

    const run_step = b.step("run", "run");
    run_step.dependOn(&run_cmd.step);

    // TODO : test step
}
