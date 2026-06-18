//! Path 2 — **skeletal / skinned** animation, loaded from glTF via `gltf.zig`
//! (cgltf).
//!
//! Structure only — nothing implemented. When built out, this module will
//! describe a skeleton (joint hierarchy + bind pose) and a clip as sampled
//! TRS channels per joint. It owns no timeline logic — the framework's
//! animation abstraction drives playback; this path just answers "what is the
//! joint pose / palette, given a phase?".
