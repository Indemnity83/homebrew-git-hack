class GitHack < Formula
  desc "AI-augmented git workflow CLI using llm and git-town"
  homepage "https://github.com/indemnity83/homebrew-git-hack"
  url "https://github.com/indemnity83/homebrew-git-hack/releases/download/v0.1.3/git-hack"
  sha256 "a5cb3a350e254c5de50f64329717f3e28774ccebe3f4e4184ca0ba0398dbd782"
  license "MIT"

  depends_on "git-town"
  depends_on "llm"
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
