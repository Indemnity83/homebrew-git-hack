class GitHack < Formula
  desc "AI-augmented git workflow CLI using llm and git-town"
  homepage "https://github.com/indemnity83/homebrew-git-hack"
  url "https://github.com/indemnity83/homebrew-git-hack/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "PLACEHOLDER"
  license "MIT"

  depends_on "git-town"
  depends_on "simonw/llm/llm"
  depends_on "fzf"
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
    EOS
  end

  test do
    assert_match "Usage", shell_output("#{bin}/git-hack --help")
  end
end
