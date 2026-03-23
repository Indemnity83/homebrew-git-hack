class GitHack < Formula
  desc "AI-augmented git workflow CLI using llm and git-town"
  homepage "https://github.com/indemnity83/homebrew-git-hack"
  url "https://github.com/indemnity83/homebrew-git-hack/releases/download/v0.1.4/git-hack"
  sha256 "a5cb3a350e254c5de50f64329717f3e28774ccebe3f4e4184ca0ba0398dbd782"
  license "MIT"

  resource "manpage" do
    url "https://github.com/indemnity83/homebrew-git-hack/releases/download/v#{version}/git-hack.1"
    sha256 "d305c6512bb2f0141478dce5a34243494d73afed6b711bb60ff75ea365d4c886"
  end

  depends_on "git-town"
  depends_on "llm"
  depends_on "gh"

  def install
    bin.install "git-hack"
    resource("manpage").stage { man1.install "git-hack.1" }
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
