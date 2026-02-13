# dotfiles-pub bash prompt experiments (archived)

이 폴더는 `submodules/dotfiles-pub`의 기존 프롬프트 테마 실험 환경을 백업한 것입니다.

## Archived files

- `prompt-themes/`
  - `minimal.bashrc`
  - `starship.bashrc`
  - `powerline-go.bashrc`
  - `liquidprompt.bashrc`
- `scripts/`
  - `prompt_theme_bootstrap.sh`
  - `prompt_theme_demo.sh`
- `README.dotfiles-pub.md`
  - 백업 당시의 dotfiles-pub 문서 원본

## Archived prompt candidates

- [Starship](https://github.com/starship/starship)
  - 멀티셸 프롬프트 엔진, 모듈식 구성, 빠르고 확장성 좋음
- [powerline-go](https://github.com/justjanne/powerline-go)
  - Go 기반 파워라인 스타일 프롬프트, 가볍고 빠름
- [Liquid Prompt](https://github.com/nojhan/liquidprompt)
  - Bash 전용, 작업 상태 상세 표시형 프롬프트

현재 dotfiles-pub은 위 내용 대신 `bashrc.template`에 기본 프롬프트를 직접 포함하는 방식으로 운영합니다.

## 복원 가이드

다시 실험 환경이 필요하면 다음으로 되돌릴 수 있습니다.

```bash
cp -R /Users/ncai/.dotfiles/_hub/_data/bak/bash_prompt/prompt-themes /Users/ncai/.dotfiles/submodules/dotfiles-pub/
cp -R /Users/ncai/.dotfiles/_hub/_data/bak/bash_prompt/scripts /Users/ncai/.dotfiles/submodules/dotfiles-pub/
cp /Users/ncai/.dotfiles/_hub/_data/bak/bash_prompt/README.dotfiles-pub.md /Users/ncai/.dotfiles/submodules/dotfiles-pub/README.md
# in submodule root:
cp ./_hub/_data/bak/bash_prompt/README.dotfiles-pub.md ./README.md
```
