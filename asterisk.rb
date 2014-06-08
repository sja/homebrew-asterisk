require 'formula'

class Asterisk < Formula
  homepage 'http://www.asterisk.org'
  url 'http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-12.3.0.tar.gz'
  sha1 '2d9369b32ec4cadad5189dda314204a15f160bb0'

  depends_on 'gcc48'
  depends_on 'gmime'
  depends_on 'iksemel'
  depends_on 'jansson'
  depends_on 'ncurses'
  depends_on 'openssl'
  depends_on 'pjsip'
  depends_on 'pkg-config' => :build
  depends_on 'speex'
  depends_on 'sqlite'
  depends_on 'srtp'
  depends_on 'unixodbc'

  def install
    openssl = Formula['openssl']
    sqlite = Formula['sqlite']
    unixodbc = Formula['unixodbc']

    # Asterisk does not build with clang; only GCC
    ENV["CC"]  = "/usr/local/bin/gcc-4.8"
    ENV["CXX"] = "/usr/local/bin/g++-4.8"
    # Some Asterisk code doesn't follow strict aliasing rules
    ENV["CFLAGS"] = "-fno-strict-aliasing"
    ENV["PKG_CONFIG"] = "/usr/local/bin/pkg-config"

    system "./configure", "--prefix=#{prefix}",
                          "--without-netsnmp",
                          "--without-gtk2",
                          "--with-ssl=#{openssl.opt_prefix}",
                          "--with-sqlite3=#{sqlite.opt_prefix}",
                          "--with-unixodbc=#{unixodbc.opt_prefix}"

    system "make", "menuselect/cmenuselect",
                   "menuselect/nmenuselect",
                   "menuselect/gmenuselect",
                   "menuselect/menuselect",
                   "menuselect-tree",
                   "menuselect.makeopts"

    # Inline function cause errors with Homebrew's gcc-4.8
    system "menuselect/menuselect",
           "--enable", "DISABLE_INLINE", "menuselect.makeopts"
    # Native compilation doesn't work with Homebrew's gcc-4.8
    system "menuselect/menuselect",
           "--disable", "BUILD_NATIVE", "menuselect.makeopts"

    system "make", "all", "NOISY_BUILD=yes"
    system "make", "install"
  end
end
