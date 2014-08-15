require "formula"

class Emboss < Formula
  homepage "http://emboss.sourceforge.net/"
  url "ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-6.6.0.tar.gz"
  mirror "ftp://ftp.ebi.ac.uk/pub/software/unix/EMBOSS/EMBOSS-6.6.0.tar.gz"
  mirror "https://science-annex.org/pub/emboss/EMBOSS-6.6.0.tar.gz"
  sha1 "93749ebd0a777efd3749974d2401c3a2a013a3fe"

  option "with-embossupdate", "Run embossupdate after `make install`"

  depends_on "pkg-config" => :build
  depends_on "libharu"    => :optional
  depends_on "gd"         => :optional
  depends_on :libpng      => :recommended
  depends_on :x11         => :recommended

  def install
    inreplace "Makefile.in", "$(bindir)/embossupdate", "" if build.without? "embossupdate"

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-64
      --with-thread
    ]
    args << "--without-x" if build.without? "x11"

    system "./configure", *args
    system "make", "install"
  end
end
