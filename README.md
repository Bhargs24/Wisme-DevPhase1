# Wisme, Phase 1

**The first build of the app that became [Wivme](https://wivmeai.com).** Pick a topic, get a short podcast-style lesson generated for it, listen, and keep track of what you covered.

Built July 2025. Kept here as it was, under the original "Wisme" spelling. Not maintained.

## What it does

- **Generates the lesson.** A topic goes in, an LLM writes a short spoken lesson for it.
- **Reads it aloud.** Two voice coaches with different personalities, through text to speech.
- **Tracks progress.** Streaks, achievements and a leaderboard over what you have listened to.
- **Works offline.** Lessons download so they play without a connection.

## Layout

The Flutter project is in [`wisme_app/`](wisme_app/), with the source under `wisme_app/lib/` split into `UI`, `services`, `repositories`, `models`, `providers` and a `design_system`. The development notes from the build are the markdown files alongside it.

## Stack

Flutter and Dart, an LLM for lesson generation, TTS for the audio. Runs on Android, iOS and web.

## Running it

```bash
cd wisme_app
cp .env.example .env      # add your own API keys
flutter pub get
flutter run
```

No keys are committed. `.env.example` lists the ones you need.

## What came after

Phase 1 was there to answer one question: is a generated audio lesson actually worth listening to. It was, but listening alone did not make anything stick, which is the gap the later work went after. That became Wivme: the same audio-first idea, plus the part this version had no answer for, a spaced-repetition engine that decides when a concept has faded and brings it back.

## Status

Archived prototype from July 2025. It is here as a record of where the product started, not as something to run in production.
