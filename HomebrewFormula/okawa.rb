# frozen_string_literal: true

# Homebrew tap formula template for okawa.
# To use it, create a tap repository (e.g. github.com/linooohon/homebrew-okawa)
# with a `Formula` directory and drop this file in as `Formula/okawa.rb`.
class Okawa < Formula
  desc "Menu bar input source switcher with custom shortcuts"
  homepage "https://github.com/linooohon/okawa"
  url "https://github.com/linooohon/okawa.git",
      :using => :git,
      :branch => "main"
  version "1.2.0"

  depends_on :xcode => ["15.0", :build]

  def install
    system "xcodebuild",
           "-scheme", "okawa",
           "-configuration", "Release",
           "-derivedDataPath", "build",
           "CODE_SIGN_IDENTITY=",
           "CODE_SIGNING_REQUIRED=NO"

    app_path = "build/Build/Products/Release/okawa.app"
    prefix.install app_path
    bin.install_symlink "#{app_path}/Contents/MacOS/okawa" => "okawa"
  end

  def caveats
    <<~EOS
      The app is installed to:
        #{opt_prefix}/okawa.app
      A CLI shim is available at:
        #{opt_bin}/okawa
    EOS
  end
end
