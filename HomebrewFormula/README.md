# Homebrew tap packaging

This directory contains templates for a Homebrew tap. Steps:

1) Create a repository `homebrew-okawa` or `homebrew-tap` (one per account).
2) Inside the repo create a `Formula/` directory and place `okawa.rb` from this directory.
3) (Optional for binary install) Create a `Casks/` directory and add a cask pointing to the release asset `okawa.zip` (see GitHub Actions below).
4) Push the repository. Users can then install:
   ```bash
   brew tap linooohon/okawa   # or linooohon/tap
   brew install linooohon/okawa/okawa        # formula from source
   brew install --cask linooohon/okawa/okawa # prebuilt .app from release
   ```

If the tap lives in this repository (not in a separate `homebrew-okawa`), connect with URL:
```bash
brew tap linooohon/okawa https://github.com/linooohon/okawa
```

## Release pipeline

The workflow `.github/workflows/release.yml` builds `okawa.app` on tag push and attaches `okawa.zip` to the GitHub Release. This is used by the cask (install without Xcode).

## Formula settings

- The formula `okawa.rb` currently tracks the `main` branch. When releasing a tag, update `version` and/or switch to a tarball release URL.
- For the cask, use a URL like `https://github.com/linooohon/okawa/releases/download/v1.1.0/okawa.zip` and set `sha256` from the CI artifact.
