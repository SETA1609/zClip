//! Path 1 — 2D sprite-sheet **atlas** animation.
//!
//! Structure only — nothing implemented. When built out, this module will
//! describe a sprite sheet as a grid/list of frame sub-rectangles and a clip
//! as an ordered sequence of those frames with per-frame durations. It owns
//! no timeline logic — the framework's animation abstraction drives playback;
//! this path just answers "which frame rect, given a phase?".
