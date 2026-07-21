TASK-009: Commit the licensed primary-touch SFX reference
Status: ready
Complexity: routine
Files: create res://assets/audio/reference/ui_tap_soft_kenney_click1.wav and its Godot import sidecar, create res://assets/licenses/audio/ui_tap_soft_kenney_click1.md
Acceptance:
- Download the exact archive at `https://opengameart.org/sites/default/files/UI_SFX_Set.zip`, verify byte size `1,425,902` and SHA-256 `66026B9E39859B85964DBB3EE7A2D1FC46A6A406BB3E97C8B0DEFEE0E25FB369`, and extract only its root entry `click1.wav`; do not commit the ZIP or any other archive entry
- Save the extracted entry as `ui_tap_soft_kenney_click1.wav` without transcoding, trimming, normalizing, tagging, resampling, fading, layering, or any other byte change; it must remain exactly `16,596` bytes with SHA-256 `359C8C98ECD48368F45B84D3A9B9D7E68CF3AC2FEFCDBF32367B8482DA76C9C7`
- The committed WAV decodes completely without error; record its duration, channel count, sample rate, bit depth or sample format, codec, frame count, measured peak level, leading-silence duration, and clipped-sample count in the license record and Coder report
- Listening confirms one short, soft, organic tap suitable for immediate primary button or world-touch confirmation, with no speech, musical phrase, harsh buzzer, metallic clang, combat hit, horror sound, distortion, corruption, clipped tail, or distracting volume
- The audible response begins promptly after playback starts and ends cleanly; two manual triggers with a short pause sound consistent and distinct without requiring a loop or sustained tail
- `ui_tap_soft_kenney_click1.md` records pack title `51 UI sound effects (buttons, switches and clicks)`, creator `Kenney Vleugels`, credit identity `Kenney`/`www.kenney.nl`, OpenGameArt source-page URL, direct ZIP URL, UTC access date, archive filename/size/SHA-256, exact entry name/size/SHA-256, committed filename/SHA-256, technical properties, unmodified status, and intended primary-touch reference role
- The license record transcribes the short bundled `readme.txt` notice, identifies `CC0 1.0 Universal`, links `https://creativecommons.org/publicdomain/zero/1.0/`, states that the OpenGameArt source page displays the pack under CC0, and records the planned credit `UI sound effect from Kenney UI SFX Set - www.kenney.nl - CC0 1.0`
- The license record distinguishes verified page/archive facts from TopFarmer review notes and does not claim that Kenney, OpenGameArt, or Creative Commons endorses TopFarmer
- The WAV is a source reference only; no runtime-converted audio is created and no game scene, resource, script, audio bus, autoload, or project setting references it yet
- The existing project boot and balance-loader checks still pass
Human check:
- Double-click `ui_tap_soft_kenney_click1.wav` twice with a short pause; each playback should produce one brief, gentle, organic tap that starts quickly and ends cleanly
- Reject it if it sounds like a harsh buzzer, metallic clang, combat impact, frightening noise, musical phrase, distorted sound, delayed response, or abruptly chopped tail
- Open `assets/licenses/audio/ui_tap_soft_kenney_click1.md`; it should identify Kenney Vleugels and `www.kenney.nl`, name `click1.wav`, show the OpenGameArt and CC0 links, say the file is unmodified, and include the planned credit line
- If the tap would become irritating when heard repeatedly during ordinary play, reject it and tell the PM what you heard; do not approve it only because the file and license checks pass
Depends on: TASK-008
Notes: see DEC-027 and DEC-028. This is the Phase 1 SFX consistency reference and the candidate sound for primary touch confirmation in Phase 2; assigning it here does not yet add it to runtime. Credit Kenney even though CC0 and the bundled notice do not require attribution. If the exact archive, hash, root entry, or entry hash differs, report a blocker and do not substitute another sound or archive member.
