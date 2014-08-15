require 'formula'

class AdolC < Formula
  homepage "https://projects.coin-or.org/ADOL-C"
  url "http://www.coin-or.org/download/source/ADOL-C/ADOL-C-2.5.1.tgz"
  sha1 "c609da3645acfbcf73e3be95861dcd6f7b5fc5db"

  head 'https://projects.coin-or.org/svn/ADOL-C/trunk/', :using => :svn

  depends_on :autoconf => :build
  depends_on :automake => :build
  depends_on :libtool  => :build
  depends_on "colpack" => [:recommended, 'with-libc++']

  fails_with :llvm

  fails_with :gcc do
    build 5666
    cause "C++ compilation error."
  end

  def install
    ENV.cxx11 if ENV.compiler == :clang

    # Configure may get automatically regenerated. So patch configure.ac.
    inreplace %w(configure configure.ac) do |s|
      s.gsub! "lib64", "lib"
    end

    args =  ["--prefix=#{prefix}", "--enable-sparse"]
    args << "--with-colpack=#{Formula["colpack"].opt_prefix}" if build.with? "colpack"
    args << "--with-openmp-flag=-fopenmp" if ENV.compiler != :clang
    args << "--enable-ulong" if MacOS.prefer_64_bit?

    ENV.append_to_cflags   "-I#{buildpath}/ADOL-C/include/adolc"
    system "./configure", *args
    system "make install"
    system "make test"
  end
end
