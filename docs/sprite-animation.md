# Sprite-atlas animation — theory & usage

zClip's sprite-atlas path drives 2D frame-by-frame animation from a sprite sheet (a single texture containing every frame side by side). It is **pure Zig**, has no external dependencies, and answers one question: *given a phase in `[0,1]`, which frame rect should I draw?*

## Core concepts

### Sprite sheet

A sprite sheet is a single texture that packs every animation frame as a sub-rectangle arranged in a grid or packed layout. The image data lives in the renderer (zClip never touches it); zClip only manages the **metadata** — the per-frame sub-rectangle positions and durations.

### Frame (`Frame`)

The atomic unit of sprite animation: which sub-rectangle of the sheet to show (`Rect`) and for how long (`duration` in seconds). Durations let you create non-uniform timing — a punch frame holds for 0.05s, a recovery hold for 0.3s.

### Atlas (`Atlas`)

A collection of frames describing a single sprite sheet. Owns the frame slice; you must `deinit` it when done. Two construction paths:

- **`Atlas.grid`** — programmatic grid: give it columns, rows, frame size, and total duration. Each frame gets equal time. Good for sprite sheets exported as uniform grids.
- **`Atlas.parse`** — JSON deserialisation: load from external tool output (e.g. Aseprite's JSON export, TexturePacker). Each frame specifies its own rect and duration individually.

### Clip (`Clip`)

An ordered sequence of frames taken from an atlas (not necessarily all of them — a sheet can hold many clips). The clip borrows the frame slice; you keep the atlas alive while the clip is in use.

- `Clip.init(frames)` — picks frames and pre-computes `duration` (sum of per-frame durations).
- `Clip.frameAt(phase)` — the core query: `phase` is `[0, 1]` where `0` = start of the clip, `1` = end. Returns the frame to display.

## Frame lookup algorithm

`frameAt` walks frames linearly, accumulating each frame's duration until the accumulated time exceeds `phase × clip.duration`:

```
phase 0.0 ───────┬──────┬──────────────────┬──────► 1.0
                  │  f0  │       f1         │  f2
                  │ 0.2s │      0.5s        │ 0.3s
                  │      │                  │
target = 0.4 × 1.0 = 0.4s → lands in f1
```

The clip owns no timeline policy (loop, ping-pong, speed) — that lives in the framework's `Animator`. The raw `Clip` is a pure data query: give it a phase, get a frame.

## Usage pattern

```
Load sprite sheet texture (PNG) ──► renderer owns the GPU image
         │
Load atlas metadata (JSON) ──────► Atlas.parse → owns Frame slice
         │
Pick frames for a clip ──────────► Clip.init → borrows slice
         │
Each frame: advance phase ───────► Clip.frameAt(phase) → current Frame.rect
         │
Draw using that rect ────────────► renderer blits sub-rectangle from sheet
```

The renderer loads the texture once; zClip handles the metadata. Neither knows about the other — you pair them at the call site.

## When to use sprite animation

Good fit for:
- 2D characters with hand-drawn or pixel-art frames
- UI transitions, destruction FX, environmental loops
- Any animation where each frame is a completely different image (no interpolation between them)
- Low-complexity projects where a skeletal rig is overkill

Not a good fit for:
- 3D or 2.5D skeletal animation — use the skeletal path
- Animations with hundreds of near-identical frames (a skeletal rig compresses better)
- Procedural interpolation between poses (skeletal blending)

## JSON format reference

`Atlas.parse` expects this structure:

```json
{
  "frames": [
    {"x": 0,   "y": 0,   "w": 64, "h": 64, "duration": 0.1},
    {"x": 64,  "y": 0,   "w": 64, "h": 64, "duration": 0.1},
    {"x": 128, "y": 0,   "w": 64, "h": 64, "duration": 0.2}
  ]
}
```

| Field | Type | Meaning |
|-------|------|---------|
| `x`, `y` | integer | Top-left corner of the frame on the sprite sheet (pixels). |
| `w`, `h` | integer | Dimensions of the frame (pixels). |
| `duration` | float | How long this frame is visible (seconds). |

The format is deliberately minimal — it maps one-to-one to `Frame[]`. Convert from your tool's export (Aseprite, TexturePacker, etc.) at the call site or with a small adapter.
