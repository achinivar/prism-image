# Prism OS

A Linux distribution built around a simple idea: local AI should just work.

## The problem

The open-source AI ecosystem has never been more capable. There are excellent models, inference engines, voice tools, and agents — all free, all running on consumer hardware and none of it sending your data anywhere.

But using any of it means figuring out installation of missing drivers, manual configurations, setting up local run-times, containers and guard-rails and deciding which model to use - all of which can be daunting to an everyday user. 
Also, Developers who want to ship AI-powered apps have no stable platform to target. 

## What Prism OS is

Prism OS is an opinionated Linux desktop that ships the capability to run local AI as a first-class feature of the operating system, not as an add-on or a tutorial or a script you found on Reddit.

It is built on [Fedora Silverblue](https://fedoraproject.org/silverblue/) (immutable and reliable) using the [Universal Blue](https://universal-blue.org/) toolchain. It comes with a curated local inference stack pre-configured and running on first boot. Text, voice, and embeddings are all available to apps through a single, stable API without any setup or cloud subscription required.

For **everyday users**, it means being able to run local agents and AI tools the same way you'd open any other app.

For **developers**, it means a real platform to build and ship AI-native applications against — with a consistent API surface, predictable hardware targets, and users who are already set up to run what you make.

## How it's built

Prism OS is distributed as a signed OCI image (for users rebasing from Fedora Silverblue or Universal Blue) and a standalone ISO for fresh installs (work in progress). The system is immutable and the AI stack is part of the image itself.

Applications talk to a local OpenAI-compatible endpoint. The OS handles everything underneath: model selection, hardware acceleration, context management. Apps don't need to know how any of it works.

## How to Install in a Fedora Silverblue based distro

1. Check what you're currently booted into:
   ```bash
   sudo bootc status
   ```

2. Switch to Prism OS with the command below and restart your computer
   ```bash
   sudo bootc switch ghcr.io/achinivar/prism-image:latest
   ```

3. If you need to roll back: Run the command below and restart your computer
   ```bash
   sudo bootc rollback
   ```

## Built on

- [Fedora Silverblue](https://fedoraproject.org/silverblue/) — immutable Fedora base
- [Universal Blue](https://universal-blue.org/) — OCI image toolchain
- [Flatpak](https://flatpak.org/) — application delivery

## Status

Prism OS is in active development and is not yet ready for testing. 
