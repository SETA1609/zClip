pub const Interpolation = enum(u2) {
    step,
    linear,
    cubic_spline,
};

pub const ChannelTarget = enum(u3) {
    translation,
    rotation,
    scale,
    weights,
};

pub const PathKind = enum(u1) {
    sprite,
    skeletal,
};

pub const Channel = struct {
    joint_index: usize,
    sampler: Sampler,
    target: ChannelTarget,
};

pub const Sampler = struct {
    interpolation: Interpolation,
    input: []const f32,
    output: []const f32,
};

pub const Joint = struct {
    name: []const u8,
    parent: ?usize,
    inverse_bind_matrix: [16]f32,
};

pub const JointPalette = struct {
    matrices: []const [16]f32,
};

pub const Clip = struct {
    duration: f32,
    channels: []const Channel,

    pub fn init(duration: f32, channels: []const Channel) Clip {
        _ = duration;
        _ = channels;
        @panic("TODO");
    }

    pub fn sample(clip: Clip, phase: f32, palette: *JointPalette) void {
        _ = clip;
        _ = phase;
        _ = palette;
        @panic("TODO");
    }
};

pub const Skeleton = struct {
    joints: []const Joint,

    pub fn init(joints: []const Joint) Skeleton {
        _ = joints;
        @panic("TODO");
    }

    pub fn bakeJointPalette(skeleton: Skeleton, phase: f32) JointPalette {
        _ = skeleton;
        _ = phase;
        @panic("TODO");
    }
};
