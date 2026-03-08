class GitHack < Formula
  desc "AI-augmented git workflow CLI using llm and git-town"
  homepage "https://github.com/indemnity83/homebrew-git-hack"
  url "https://github.com/indemnity83/homebrew-git-hack/releases/download/v0.1.0/git-hack"
  sha256 "7dfd1d743fbc59ab4361455a58a9615e926091da240ae0018c54c19069f184f1"
  license "MIT"

  depends_on "git-town"
  depends_on "simonw/llm/llm"
  depends_on "gh"

  def install
    bin.install "git-hack"
  end

  def caveats
    <<~EOS
      Run once per repo to configure git-town branch tracking:
        git town config setup

      Optional: install git shorthand aliases (snap, propose, etc.):
        git hack init

      For improved selection UI, install fzf:
        brew install fzf
    EOS
  end

  test do
    assert_match "Usage", shell_output("#{bin}/git-hack --help")
  end
end
