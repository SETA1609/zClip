# Skeletal animation — theory & usage

zClip's skeletal path drives **skinned** animation loaded from glTF 2.0 files. It uses the vendored [cgltf](https://github.com/jkuhlmann/cgltf) parser to ingest glTF data and answers: *given a phase in `[0,1]`, what is the per-joint transform palette needed to skin my mesh?*

> **Status: planned** — the API surface is declared but all functions panic. This doc describes the intended design. See [`ROADMAP.md`](ROADMAP.md) for the implementation timeline.

## Core concepts

### Skeleton

A hierarchy of **joints** (bones) arranged in a tree. Each joint has:
- A **name** for identification.
- A **parent** index (or `null` for the root).
- An **inverse bind matrix** — the transform that bakes the mesh into the joint's local space at rest pose.

The skeleton is built from glTF's `skin` + `node` data: cgltf gives us the raw hierarchy and inverse-bind matrices; zClip owns them as `skeletal.Joint[]`.

### Clip (skeletal)

A skeletal clip holds **channels**: one per animated joint property (translation, rotation, scale). Each channel references a **sampler** that stores the keyframe timeline (`input`: times array) and keyframe values (`output`: TRS array). Interpolation between keyframes is one of `step`, `linear`, or `cubic_spline`.

A clip does not own a skeleton — it just describes motion. The same clip can play on any skeleton with matching joint topology.

### Joint palette

The output of the animation system: one 4×4 matrix per joint, computed by:
1. Sampling each channel at the current phase → per-joint local TRS.
2. Walking the skeleton hierarchy: each joint's world transform = parent's world × local TRS.
3. Multiplying by the inverse bind matrix → final skinning matrix.

The palette is uploaded to the GPU as a storage buffer and indexed by the vertex shader during skinning.

## Pipeline

```
glTF file ──► cgltf (C parser) ──► gltf.zig binding ──► owned Zig Document
                                                          │
                      ┌───────────────────────────────────┤
                      ▼                                   ▼
                Skeleton (joint tree)               Clip (channels)
                      │                                   │
                      │            ┌──────────────────────┘
                      ▼            ▼
              Skeleton.bakeJointPalette(phase)
                      │
                      ▼
              JointPalette → GPU storage buffer → vertex shader skinning
```

1. **Load glTF**: `gltf.loadFile(allocator, path)` → `Document` (cgltf parses the file; zClip owns the result).
2. **Build skeleton**: iterate the glTF skin's joint nodes → `skeletal.Skeleton` (parent indices, inverse-bind matrices).
3. **Extract clips**: iterate the glTF animation array → `skeletal.Clip[]` (channels from the animation samplers).
4. **Sample**: each frame, advance phase by `dt / clip.duration`, call `clip.sample(phase, &palette)`.
5. **Bake**: `skeleton.bakeJointPalette(phase)` → `JointPalette` (array of 4×4 matrices).
6. **Render**: upload the palette, bind it, draw the skinned mesh.

## Interpolation modes

| Mode | Behaviour | Use case |
|------|-----------|----------|
| `step` | Hold the previous value until the exact keyframe time. | Robot/mechanical motion, sudden transitions. |
| `linear` | LERP between keyframes. | General-purpose; works for most game animations. |
| `cubic_spline` | Hermite spline through keyframes (uses tangents stored in cgltf). | Cinematic-quality motion; smooth acceleration/deceleration. |

## When to use skeletal animation

Good fit for:
- 3D characters with complex movement (walk, run, jump, attack)
- Any scenario where blending between animations is needed (crossfade, additive)
- Content authored in DCC tools (Blender, Maya) and exported to glTF
- Animations that share a skeleton but differ in motion (idle → walk → run use the same rig)

Not a good fit for:
- 2D frame-by-frame animation — use the sprite-atlas path
- Simple FX with a handful of images — sprite animation is simpler
- Procedural / physics-driven animation — zClip is a data-driven sampler

## Relationship to the sprite path

Both paths share a common contract — *pose at phase* — so the framework's `Animator` drives either identically:

| | Sprite | Skeletal |
|---|---|---|
| Input | Atlas metadata (JSON) + texture | glTF 2.0 file |
| Output | Frame rect | Joint palette |
| Phase → result | `Clip.frameAt(phase)` → `Rect` | `Skeleton.bakeJointPalette(phase)` → `JointPalette` |
| Interpolation | Discrete (frame snap) | Continuous (step/linear/spline) |
| Dependencies | None (pure Zig) | cgltf (vendored C) |
| Best for | 2D, pixel art, FX | 3D, characters, blending |
