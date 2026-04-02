class GitHack < Formula
  desc "AI-augmented git workflow CLI using llm and git-town"
  homepage "https://github.com/indemnity83/homebrew-git-hack"
  url "https://github.com/indemnity83/homebrew-git-hack/releases/download/v0.1.7/git-hack"
  sha256 "95fd71000c532ca5186ec201c317c6bbf9000d131218b9691d8ba0fc342507e4"
  license "MIT"

  resource "manpage" do
    url "https://github.com/indemnity83/homebrew-git-hack/releases/download/v0.1.7/git-hack.1"
    sha256 "baf1ac1834e8d77a5f074576f3a5e5088e590124fb2e339167fdac92b1b6f78c"
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
