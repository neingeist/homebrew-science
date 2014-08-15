require 'formula'

class SuiteSparse < Formula
  homepage 'http://www.cise.ufl.edu/research/sparse/SuiteSparse'
  url 'http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-4.2.1.tar.gz'
  mirror 'http://pkgs.fedoraproject.org/repo/pkgs/suitesparse/SuiteSparse-4.2.1.tar.gz/4628df9eeae10ae5f0c486f1ac982fce/SuiteSparse-4.2.1.tar.gz'
  sha1 '2fec3bf93314bd14cbb7470c0a2c294988096ed6'

  option "with-matlab", "Install Matlab interfaces and tools"
  option "with-matlab-path=", "Path to Matlab executable (default: matlab)"

  depends_on "tbb" => :recommended
  depends_on "openblas" => :optional
  depends_on "metis4" => :optional # metis 5.x is not yet supported by suite-sparse

  # Mathworks only support gcc/gfortran 4.3 on OSX.
  depends_on "homebrew/versions/gcc43" => [:build, "enable-fortran"] if build.with? "matlab"

  def install
    # SuiteSparse doesn't like to build in parallel
    ENV.deparallelize

    # Switch to the Mac base config, per SuiteSparse README.txt
    system "mv SuiteSparse_config/SuiteSparse_config.mk SuiteSparse_config/SuiteSparse_config_orig.mk"
    system "mv SuiteSparse_config/SuiteSparse_config_Mac.mk SuiteSparse_config/SuiteSparse_config.mk"

    make_args = ["INSTALL_LIB=#{lib}", "INSTALL_INCLUDE=#{include}"]
    make_args << "BLAS=" + ((build.with? 'openblas') ? "-L#{Formula['openblas'].opt_lib} -lopenblas" : "-framework Accelerate")
    make_args << "LAPACK=$(BLAS)"
    make_args += ["SPQR_CONFIG=-DHAVE_TBB", "TBB=-L#{Formula['tbb'].opt_lib} -ltbb"] if build.with? "tbb"
    make_args += ["METIS_PATH=", "METIS=-L#{Formula['metis4'].opt_lib} -lmetis"] if build.with? "metis4"

    system "make", "library", *make_args
    lib.mkpath
    include.mkpath
    system "make", "install", *make_args

    matlab = ARGV.value("with-matlab-path") || "matlab"
    if build.with? "matlab"
      system matlab, "-nodesktop", "-nosplash", "-r", "run('SuiteSparse_install(false)'); exit;"

      # Install Matlab scripts and Mex files.
      %w[AMD BTF CAMD CCOLAMD CHOLMOD COLAMD CSparse CXSparse KLU LDL SPQR UMFPACK].each do |m|
        (share / "suite-sparse/matlab/#{m}").install Dir["#{m}/MATLAB/*"]
      end

      mdest = share / "suite-sparse/matlab"
      mdest.install "MATLAB_Tools"
      mdest.install "RBio/RBio"
    end
  end

  def caveats
    s = ""
    if build.with? "matlab"
      s += <<-EOS.undent
        Matlab interfaces and tools have been installed to

          #{share}/suite-sparse/matlab
      EOS
    end
    return s
  end
end
