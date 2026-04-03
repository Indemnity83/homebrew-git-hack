class GitHack < Formula
  desc "AI-augmented git workflow CLI using llm and git-town"
  homepage "https://github.com/indemnity83/homebrew-git-hack"
  url "https://github.com/indemnity83/homebrew-git-hack/releases/download/v0.1.8/git-hack"
  sha256 "85a019daed7217a59574aa8b448977ea3e18f3857633bbc95001dedb1b6971cc"
  license "MIT"

  resource "manpage" do
    url "https://github.com/indemnity83/homebrew-git-hack/releases/download/v0.1.8/git-hack.1"
    sha256 "c9855fb5f2250693d8cb82c9013055f0d3b72b42bb15cad216aee7f6394b555e"
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
