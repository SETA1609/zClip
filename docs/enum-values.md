# Enum values — zClip

All enum tags are defined with explicit backing integers to guarantee stable
discriminants across compiler versions. Contract tests in
`src/tests/contract_test.zig` assert these exact values.

## `sprite.PlayMode` (`u2`)

| Tag | Value | Meaning |
| --- | ----- | ------- |
| `once` | 0 | Play through once, then stay on the last frame. |
| `loop` | 1 | Restart from the beginning when the clip ends. |
| `ping_pong` | 2 | Play forward, then reverse, cycling back and forth. |

## `skeletal.Interpolation` (`u2`)

| Tag | Value | Meaning |
| --- | ----- | ------- |
| `step` | 0 | Hold the previous value until the next keyframe. |
| `linear` | 1 | Linear blend between keyframes (LERP). |
| `cubic_spline` | 2 | Cubic spline (Hermite) interpolation. |

## `skeletal.ChannelTarget` (`u3`)

| Tag | Value | Meaning |
| --- | ----- | ------- |
| `translation` | 0 | TRS translation channel (`vec3`). |
| `rotation` | 1 | TRS rotation channel (`vec4` quaternion). |
| `scale` | 2 | TRS scale channel (`vec3`). |
| `weights` | 3 | Morph-target weight channel. |

## `skeletal.PathKind` (`u1`)

| Tag | Value | Meaning |
| --- | ----- | ------- |
| `sprite` | 0 | A sprite-atlas clip (`zclip.sprite.Clip`). |
| `skeletal` | 1 | A skeletal clip (`zclip.skeletal.Clip`). |
