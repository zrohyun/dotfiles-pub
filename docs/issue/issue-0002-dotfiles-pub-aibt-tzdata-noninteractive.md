# Issue 0002: aibt tzdata noninteractive options

- Issue number: `#2`
- Issue type: `Bug`
- Issue hash (GitHub node id): `I_kwDORLW9B87qv39u`
- Issue URL: `https://github.com/zrohyun/dotfiles-pub/issues/2`
- Status: `Closed`
- Root repo: `submodules/dotfiles-pub`
- Closed at: `2026-02-13T18:13:51Z`

## Problem

Running `aibt` after dotfiles-pub install could block on tzdata geographic area/city prompts, which breaks automation and scripted installs.

## Root cause

The `apt_install_basic_tools` helper ran `apt` interactively and did not provide a noninteractive option or a TZ override for tzdata.

## Resolution

- Added optional noninteractive and TZ environment handling to `apt_install_basic_tools` in `submodules/dotfiles-pub/install.sh`.
- Documented two noninteractive approaches and the new env vars in `submodules/dotfiles-pub/README.md`.
- Ensured `sudo` preserves `DEBIAN_FRONTEND`/`TZ` by applying env vars after `sudo` and skipping `sudo` when already root.

## Validation

- Manual review: `DOTFILES_AIBT_NONINTERACTIVE=1 DOTFILES_TZ=Asia/Seoul aibt` now avoids tzdata prompts.

## Traceability

- Closing commits:
  - `c3b01a3` (implementation: `fix(install): allow noninteractive aibt tzdata Refs #2`)
  - `__TBD__` (follow-up: preserve noninteractive env under sudo)
