# Prism OS

An opinionated, AI-first Linux distribution built on [Fedora Silverblue](https://fedoraproject.org/silverblue/) — immutable, privacy-focused, and designed to run local AI out of the box.

## What is Prism OS?

Prism OS is a curated desktop operating system for people who want capable, on-device AI without cloud dependency. It ships with a local inference stack pre-configured and ready to use — no accounts, no API keys, no data leaving your machine.

It is built on the [Universal Blue](https://universal-blue.org/) toolchain, using atomic image-based updates to keep the system stable, reproducible, and easy to maintain.

## How it works

Prism OS is distributed as two complementary artifacts:

- **OCI Image** — an immutable, signed container image hosted on the GitHub Container Registry (GHCR). Existing Fedora Silverblue or Universal Blue users can rebase onto it directly.
- **Installable ISO** — a standalone installer for fresh installs, with Flatpaks bundled and the OCI image embedded.

The local AI stack runs as a system service, exposing a standard OpenAI-compatible API endpoint to all applications. Apps can use this endpoint without knowing anything about the underlying hardware or which models are running.

## Design principles

- **Local first.** All inference runs on-device. No cloud fallback, no telemetry.
- **Immutable base.** The OS image is atomic and signed. System changes happen through image updates, not package mutations.
- **Curated, not configurable.** Prism OS makes opinionated choices so users don't have to. The AI stack, model selection, and app ecosystem are hand-picked.
- **Open API surface.** Applications talk to a single, stable OpenAI-compatible endpoint regardless of the underlying hardware.

## Built on

- [Fedora Silverblue](https://fedoraproject.org/silverblue/) — immutable Fedora base
- [Universal Blue](https://universal-blue.org/) — OCI image toolchain
- [Lemonade](https://github.com/lemonade-hq/lemonade) — local AI inference orchestration
- [Flatpak](https://flatpak.org/) — application delivery

## Status

Prism OS is in active development. Contributions and feedback are welcome.
