# Kenney click1 - Audio License and Provenance Record

## Verified Source-Page and Archive Facts

- Pack title: `51 UI sound effects (buttons, switches and clicks)`
- Creator: `Kenney Vleugels`
- OpenGameArt author identity: `Kenney`
- Credit identity: `Kenney` / `www.kenney.nl`
- OpenGameArt source page: https://opengameart.org/content/51-ui-sound-effects-buttons-switches-and-clicks
- Direct ZIP URL: https://opengameart.org/sites/default/files/UI_SFX_Set.zip
- UTC access date: `2026-07-21`
- OpenGameArt classification: sound effect
- OpenGameArt description: 51 WAV-format UI sound effects described as organic sounds, including clicks, mouse clicks, rollovers, and switches
- License displayed by the OpenGameArt source page: `CC0`
- License identification: `CC0 1.0 Universal`
- CC0 deed: https://creativecommons.org/publicdomain/zero/1.0/
- OpenGameArt optional attribution instruction: credit `Kenney.nl` or `www.kenney.nl`; the page says this is not mandatory
- Planned TopFarmer credit: `UI sound effect from Kenney UI SFX Set - www.kenney.nl - CC0 1.0`

### Verified Archive Identity

- Archive filename: `UI_SFX_Set.zip`
- Archive byte size: `1,425,902`
- Archive SHA-256: `66026B9E39859B85964DBB3EE7A2D1FC46A6A406BB3E97C8B0DEFEE0E25FB369`
- Selected root entry: `click1.wav`
- Selected entry byte size: `16,596`
- Selected entry SHA-256: `359C8C98ECD48368F45B84D3A9B9D7E68CF3AC2FEFCDBF32367B8482DA76C9C7`
- Extraction scope: only the root `click1.wav` entry was extracted; the ZIP and every other archive entry remain outside the repository

### Bundled `readme.txt` Notice

The following short notice is transcribed from the root `readme.txt` entry without extracting or committing that entry:

> ---
>
> UI SFX set by Kenney Vleugels (www.kenney.nl)
>
> You may use these sounds in personal and commercial projects.
> Credit (www.kenney.nl) would be nice but is not mandatory.
>
> --

The OpenGameArt page displays the pack under CC0, and the linked Creative Commons deed identifies the dedication as CC0 1.0 Universal. TopFarmer will provide optional credit even though neither the page nor bundled notice makes attribution mandatory. Neither Kenney Vleugels, Kenney, OpenGameArt, nor Creative Commons is claimed to endorse TopFarmer. Creative Commons has not verified the copyright status of this work and provides no warranty concerning it.

## Committed File and Technical Properties

- Committed filename: `ui_tap_soft_kenney_click1.wav`
- Repository path: `res://assets/audio/reference/ui_tap_soft_kenney_click1.wav`
- Intended role: Phase 1 primary-touch SFX consistency reference and Phase 2 candidate for immediate primary button or world-touch confirmation
- Runtime status: source reference only; not connected to a scene, resource, script, audio bus, autoload, or project setting
- Modification status: unmodified exact `click1.wav` entry bytes; no transcoding, trimming, normalization, tagging, resampling, fading, layering, or other byte change
- Godot import policy: compression disabled; forced 8-bit conversion, mono conversion, rate limiting, trimming, normalization, and loop editing are all disabled
- SHA-256: `359C8C98ECD48368F45B84D3A9B9D7E68CF3AC2FEFCDBF32367B8482DA76C9C7`
- Byte size: `16,596`
- Duration: `0.093832` seconds
- Channel count: `2` (stereo)
- Sample rate: `44,100 Hz`
- Bit depth and sample format: signed `16-bit` little-endian integer PCM
- Codec: uncompressed PCM WAV
- Frame count: `4,138`
- Decoded PCM byte count: `16,552`
- Measured sample peak: `-15.02 dBFS` (`-15.0150 dBFS` before rounding)
- Integrated sample RMS: `-38.11 dBFS`
- Leading-silence duration below `-60 dBFS`: `0.000000` seconds
- Trailing below-threshold decay: `0.046621` seconds
- Clipped full-scale samples: `0`
- Complete decode: passed; every declared PCM frame decoded and no unexpected decoded frame remained

## TopFarmer Review Notes

The archive matched both prescribed identity checks before extraction. The selected entry and committed file have identical byte size and SHA-256. Full PCM decoding completed without an error, truncated frame, corrupt chunk, or clipped sample.

The response begins above the `-60 dBFS` threshold in the first sample frame and reaches peak level at `0.019297` seconds. It then decays below `-60 dBFS` for its final `0.046621` seconds; the final millisecond peaks at only `-61.37 dBFS`, and the final stereo sample values are near zero. These measurements support prompt response, a soft level, and a clean tail without a sustained or abruptly clipped ending. The source page describes the pack as organic UI sounds, consistent with the intended short primary-touch role. No loop is required or configured.

The mandatory Human check remains the authoritative listening review: trigger the complete file twice with a short pause. Approval requires one brief, gentle, organic tap per trigger that starts promptly, ends cleanly, and remains unobtrusive without speech, a musical phrase, harsh buzzer, metallic clang, combat hit, horror sound, distortion, corruption, distracting volume, delayed response, or chopped tail.
