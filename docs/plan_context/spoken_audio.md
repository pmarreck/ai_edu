# Spoken instructions for pre-readers (BDFN, 2026-09-28)

- Every child-track instruction, prompt and control label is spoken, with a replay button. Controls, including "This isn't working right", are pictorial plus spoken.
- Audio is rendered ahead of time, never live: each clip is a content-addressed artifact keyed by hash(text, voice, engine, engine version, settings). BDFN listens to and approves each clip once, and then it is frozen. Sessions need no network, and only lesson text (never child data) goes to a TTS vendor.
- Engines: ElevenLabs (BDFN's account, highest quality); local: piper-tts 1.8.0 and espeak-ng in nixpkgs (verified 2026-09-28); kokoro is packaged only as a Python module, so it is last choice.
- Risk: isolated letter sounds. TTS is built for words and may add a vowel ("buh" for /b/) or say the letter name. Record phoneme clips from a human, or ear-check every generated one; test phoneme-input features (espeak-ng phoneme input; ElevenLabs phoneme tags, unverified) before relying on them. Pure-sound teaching guidance is expert opinion; it was not covered in the evidence review.
- Answer-leakage check: spoken instructions must not say or hint at the answer being tested (founding prompt 12.2).
