TASK-008: Commit the licensed daytime-farm music reference
Status: ready
Complexity: routine
Files: create res://assets/audio/reference/day_farm_a_small_fire_will_do.wav and its Godot import sidecar, create res://assets/licenses/audio/day_farm_a_small_fire_will_do.md
Acceptance:
- Download the exact `a_small_fire_will_do.wav` file linked by `https://opengameart.org/content/a-small-fire-will-do-calming-loop` at `https://opengameart.org/sites/default/files/a_small_fire_will_do.wav`; save it as `day_farm_a_small_fire_will_do.wav` without transcoding, trimming, normalizing, tagging, resampling, looping edits, or any other byte change
- The committed WAV is lossless and decodes completely without error; record its SHA-256, byte size, duration, channel count, sample rate, bit depth or sample format, codec, and measured peak level in the license record and Coder report
- Listening from beginning to end confirms a calm, restrained acoustic village/home loop suitable for ordinary daytime farm play, with no speech, lyrics, harsh percussion, combat cue, horror sound, UI sound, clipping, corruption, or sudden volume jump
- Two consecutive unmodified playthroughs have no obvious click, pop, or long silence at the restart boundary; this is a reference-loop review only and does not authorize editing the source
- `day_farm_a_small_fire_will_do.md` records the exact title, creator name `Cal McEachern`, OpenGameArt username `Trex0n`, source-page URL, direct-download URL, UTC access date, original filename, committed filename, SHA-256, technical properties, unmodified status, intended reference role, and the source page's optional credit request
- The license record identifies `CC0 1.0 Universal`, links `https://creativecommons.org/publicdomain/zero/1.0/`, states that the OpenGameArt source page displays the track under CC0, and records the planned credit `A Small Fire Will Do by Cal McEachern (Trex0n) - CC0 1.0`
- The license record distinguishes verified page facts from TopFarmer's review notes and does not claim that Creative Commons or the creator endorses TopFarmer
- The WAV is a source reference only; no runtime-converted audio is created and no game scene, resource, script, bus, autoload, or project setting references it yet
- The existing project boot and balance-loader checks still pass
Human check:
- Double-click `day_farm_a_small_fire_will_do.wav` and listen through the whole track; it should be calm acoustic background music with no voice, frightening sound, harsh hit, distortion, or broken playback
- Turn on Repeat in the music player and listen through one restart from the end back to the beginning; there should be no sharp click, pop, sudden loud jump, or long silent pause
- Open `assets/licenses/audio/day_farm_a_small_fire_will_do.md`; it should name Cal McEachern and Trex0n, link the OpenGameArt page and CC0 1.0 page, say the file is unmodified, and include the planned credit line
- If the track feels distracting rather than suitable for relaxed daytime farming, reject it and tell the PM what you heard; do not approve it only because the file and license checks pass
Depends on: TASK-007
Notes: see DEC-008, DEC-025, and DEC-026. This source is the daytime-farm music reference only; DEC-008 keeps quiet wrongness in altered nighttime ambience and later night content, so the daytime reference should remain warm and calm. Credit the creator even though CC0 does not require attribution because the source page requests it. If either exact URL is unavailable or the downloaded bytes cannot be verified, report a blocker and do not substitute another track.
