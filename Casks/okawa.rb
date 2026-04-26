cask "okawa" do
  version "1.1.0"
  sha256 :no_check

  url "https://github.com/linooohon/okawa/releases/download/v#{version}/okawa.zip"
  name "okawa"
  desc "Input source switcher with grouped shortcut cycling"
  homepage "https://github.com/linooohon/okawa"

  app "okawa.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/okawa.app"],
                   sudo: false
  end

  caveats <<~EOS
    macOS may still warn about the app coming from the internet. If that happens:
      xattr -dr com.apple.quarantine /Applications/okawa.app
  EOS

  zap trash: [
    "~/Library/Application Support/okawa",
    "~/Library/Caches/net.noraesae.okawa",
    "~/Library/Preferences/net.noraesae.okawa.plist",
  ]
end
