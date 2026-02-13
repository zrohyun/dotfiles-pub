# Issue 0001: bashrc.template interactive check skipped in non-PS1 shells

- Issue number: `#1`
- Issue type: `Bug`
- Issue hash (GitHub node id): `I_kwDORLW9B87qvbS-`
- Issue URL: `https://github.com/zrohyun/dotfiles-pub/issues/1`
- Status: `Closed`
- Root repo: `submodules/dotfiles-pub`
- Closed at: `2026-02-13T17:36:14Z`

## Problem

`dotfiles-pub` install flow could apply a non-interactive block in shells where `$PS1` is unset even when interactive behavior is intended, causing missed prompt initialization.

## Root cause

The previous interactive guard in `bashrc.template` depended on `PS1`:

- `[[ $- != *i* ]] && return`

In spawned/test-driven shells this state is not always present.

## Resolution

Change interactive detection in `submodules/dotfiles-pub/bashrc.template` to `$-` flag based detection.

## Validation

- Docker install test flow now enters interactive shell and applies prompt block as expected.

## Traceability

- Closing commits:
  - `36e07cc` (implementation: `fix(dotfiles-pub): stabilize local template bootstrap for tests Refs #9`)
  - `caed89f` (close record)
