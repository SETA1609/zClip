//! glTF ingestion for zClip — a thin Zig binding over **cgltf** (the single-
//! header C glTF parser). This is the data source for the skeletal path
//! (joint hierarchy + animation channels) and can also surface mesh/material
//! data a renderer needs.
//!
//! Structure only — nothing implemented. When built out, this module will:
//!   - bind the cgltf API (the C backend is vendored under `src/c`; see PLAN.md),
//!   - load a `.gltf`/`.glb` file into owned Zig structs,
//!   - expose skins, joints, and TRS animation samplers to `skeletal.zig`.
