# python-direnv-template

Just a few files for my Python workflow

1. Uses purely [direnv](https://github.com/direnv/direnv) and implemented via [nix-direnv](https://github.com/nix-community/nix-direnv).
2. Python libraries managed via `pip` with fixed dependencies in `requirements.txt`

## Steps to use

This is more of a note to self

1. Install `direnv` and `nix-direnv` (done by `home-manager` usually).
2. Go to directory and run `direnv allow`.
3. shellHook should upgrade pip and install dependencies
