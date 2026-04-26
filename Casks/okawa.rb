cask "kawa" do
  version "1.1.0"
  sha256 :no_check

  url "https://github.com/linooohon/okawa/releases/download/v#{version}/Kawa.zip"
  name "Kawa"
  desc "Input source switcher with grouped shortcut cycling"
  homepage "https://github.com/linooohon/okawa"

  app "Kawa.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Kawa.app"],
                   sudo: false
  end

  caveats <<~EOS
    macOS may still warn about the app coming from the internet. If that happens:
      xattr -dr com.apple.quarantine /Applications/Kawa.app
  EOS

  zap trash: [
    "~/Library/Application Support/Kawa",
    "~/Library/Caches/net.noraesae.Kawa",
    "~/Library/Preferences/net.noraesae.Kawa.plist",
  ]
end
