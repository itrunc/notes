#Chapter 15. Installation from Source Code

##Short Version

```bash
./configure
make
su
make install
adduser postgres
mkdir /usr/local/pgsql/data
chown postgres /usr/local/pgsql/data
su - postgres
/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data
/usr/local/pgsql/bin/postgres -D /usr/local/pgsql/data >logfile 2>&1 &
/usr/local/pgsql/bin/createdb test
/usr/local/pgsql/bin/psql test
```

##Requirements

In general, a modern Unix-compatible platform should be able to run PostgreSQL. The platforms that had received specific testing at the time of release are listed in [Section 15.6](http://www.postgresql.org/docs/9.4/interactive/supported-platforms.html) below. In the doc subdirectory of the distribution there are several platform-specific FAQ documents you might wish to consult if you are having trouble.

The following software packages are required for building PostgreSQL:

* GNU make version 3.80 or newer is required; other make programs or older GNU make versions will not work. (GNU make is sometimes installed under the name gmake.) To test for GNU make enter:

    ```bash
    make --version
    ```

* You need an ISO/ANSI C compiler (at least C89-compliant). Recent versions of GCC are recommended, but PostgreSQL is known to build using a wide variety of compilers from different vendors.
* tar is required to unpack the source distribution, in addition to either gzip or bzip2.
* The GNU Readline library is used by default. It allows psql (the PostgreSQL command line SQL interpreter) to remember each command you type, and allows you to use arrow keys to recall and edit previous commands. This is very helpful and is strongly recommended. If you don't want to use it then you must specify the *--without-readline* option to *configure*. As an alternative, you can often use the BSD-licensed *libedit* library, originally developed on NetBSD. The *libedit* library is GNU Readline-compatible and is used if libreadline is not found, or if *--with-libedit-preferred* is used as an option to *configure*. If you are using a package-based Linux distribution, be aware that you need both the readline and readline-devel packages, if those are separate in your distribution.
* The zlib compression library is used by default. If you don't want to use it then you must specify the *--without-zlib* option to configure. Using this option disables support for compressed archives in pg_dump and pg_restore.

The following packages are optional. They are not required in the default configuration, but they are needed when certain build options are enabled, as explained below:

* To build the server programming language PL/Perl you need a full Perl installation, including the libperl library and the header files. Since PL/Perl will be a shared library, the libperl library must be a shared library also on most platforms. This appears to be the default in recent Perl versions, but it was not in earlier versions, and in any case it is the choice of whomever installed Perl at your site. If you intend to make more than incidental use of PL/Perl, you should ensure that the Perl installation was built with the usemultiplicity option enabled (perl -V will show whether this is the case).

    If you don't have the shared library but you need one, a message like this will appear during the PostgreSQL build to point out this fact:

    ```
    *** Cannot build PL/Perl because libperl is not a shared library.
    *** You might have to rebuild your Perl installation.  Refer to
    *** the documentation for details.
    ```

    (If you don't follow the on-screen output you will merely notice that the PL/Perl library object, plperl.so or similar, will not be installed.) If you see this, you will have to rebuild and install Perl manually to be able to build PL/Perl. During the configuration process for Perl, request a shared library.

* To build the PL/Python server programming language, you need a Python installation with the header files and the distutils module. The minimum required version is Python 2.3. (To work with function arguments of type numeric, a 2.3.x installation must include the separately-available cdecimal module; note the PL/Python regression tests will not pass if that is missing.) Python 3 is supported if it's version 3.1 or later; but see [Section 43.1](http://www.postgresql.org/docs/9.4/interactive/plpython-python23.html) when using Python 3.

    Since PL/Python will be a shared library, the libpython library must be a shared library also on most platforms. This is not the case in a default Python installation. If after building and installing PostgreSQL you have a file called plpython.so (possibly a different extension), then everything went well. Otherwise you should have seen a notice like this flying by:

    ```
    *** Cannot build PL/Python because libpython is not a shared library.
    *** You might have to rebuild your Python installation.  Refer to
    *** the documentation for details.
    ```

    That means you have to rebuild (part of) your Python installation to create this shared library.

    If you have problems, run Python 2.3 or later's configure using the --enable-shared flag. On some operating systems you don't have to build a shared library, but you will have to convince the PostgreSQL build system of this. Consult the Makefile in the src/pl/plpython directory for details.

* To build the PL/Tcl procedural language, you of course need a Tcl installation. If you are using a pre-8.4 release of Tcl, ensure that it was built without multithreading support.

* To enable Native Language Support (NLS), that is, the ability to display a program's messages in a language other than English, you need an implementation of the Gettext API. Some operating systems have this built-in (e.g., Linux, NetBSD, Solaris), for other systems you can download an add-on package from http://www.gnu.org/software/gettext/. If you are using the Gettext implementation in the GNU C library then you will additionally need the GNU Gettext package for some utility programs. For any of the other implementations you will not need it.

* You need Kerberos, OpenSSL, OpenLDAP, and/or PAM, if you want to support authentication or encryption using those services.

* To build the PostgreSQL documentation, there is a separate set of requirements; see Section J.2.

If you are building from a Git tree instead of using a released source package, or if you want to do server development, you also need the following packages:

* GNU Flex and Bison are needed to build from a Git checkout, or if you changed the actual scanner and parser definition files. If you need them, be sure to get Flex 2.5.31 or later and Bison 1.875 or later. Other lex and yacc programs cannot be used.
* Perl 5.8 or later is needed to build from a Git checkout, or if you changed the input files for any of the build steps that use Perl scripts. If building on Windows you will need Perl in any case. Perl is also required to run some test suites.

If you need to get a GNU package, you can find it at your local GNU mirror site (see http://www.gnu.org/order/ftp.html for a list) or at ftp://ftp.gnu.org/gnu/.

Also check that you have sufficient disk space. You will need about 100 MB for the source tree during compilation and about 20 MB for the installation directory. An empty database cluster takes about 35 MB; databases take about five times the amount of space that a flat text file with the same data would take. If you are going to run the regression tests you will temporarily need up to an extra 150 MB. Use the df command to check free disk space.

##Getting The Source

The PostgreSQL 9.4.4 sources can be obtained from the download section of our website: http://www.postgresql.org/download/. You should get a file named postgresql-9.4.4.tar.gz or postgresql-9.4.4.tar.bz2. After you have obtained the file, unpack it:

```bash
gunzip postgresql-9.4.4.tar.gz
tar xf postgresql-9.4.4.tar
```

(Use bunzip2 instead of gunzip if you have the .bz2 file.) This will create a directory postgresql-9.4.4 under the current directory with the PostgreSQL sources. Change into that directory for the rest of the installation procedure.

You can also get the source directly from the version control repository, see [Appendix I](http://www.postgresql.org/docs/9.4/interactive/sourcerepo.html).

##Installation Procedure

###Configuration

The first step of the installation procedure is to configure the source tree for your system and choose the options you would like. This is done by running the configure script. For a default installation simply enter:

```bash
./configure
```

This script will run a number of tests to determine values for various system dependent variables and detect any quirks of your operating system, and finally will create several files in the build tree to record what it found. You can also run configure in a directory outside the source tree, if you want to keep the build directory separate. This procedure is also called a VPATH build. Here's how:

```bash
mkdir build_dir
cd build_dir
/path/to/source/tree/configure [options go here]
make
```

The default configuration will build the server and utilities, as well as all client applications and interfaces that require only a C compiler. All files will be installed under /usr/local/pgsql by default.

You can customize the build and installation process by supplying one or more of the following command line options to configure:

* **--prefix=PREFIX**

    Install all files under the directory PREFIX instead of /usr/local/pgsql. The actual files will be installed into various subdirectories; no files will ever be installed directly into the PREFIX directory.

    If you have special needs, you can also customize the individual subdirectories with the following options. However, if you leave these with their defaults, the installation will be relocatable, meaning you can move the directory after installation. (The man and doc locations are not affected by this.)

    For relocatable installs, you might want to use configure's --disable-rpath option. Also, you will need to tell the operating system how to find the shared libraries.

* **--exec-prefix=EXEC-PREFIX**

    You can install architecture-dependent files under a different prefix, EXEC-PREFIX, than what PREFIX was set to. This can be useful to share architecture-independent files between hosts. If you omit this, then EXEC-PREFIX is set equal to PREFIX and both architecture-dependent and independent files will be installed under the same tree, which is probably what you want.

* **--bindir=DIRECTORY**

    Specifies the directory for executable programs. The default is EXEC-PREFIX/bin, which normally means /usr/local/pgsql/bin.

* **--sysconfdir=DIRECTORY**

    Sets the directory for various configuration files, PREFIX/etc by default.

* **--libdir=DIRECTORY**

    Sets the location to install libraries and dynamically loadable modules. The default is EXEC-PREFIX/lib.

* **--includedir=DIRECTORY**

    Sets the directory for installing C and C++ header files. The default is PREFIX/include.

* **--datarootdir=DIRECTORY**

    Sets the root directory for various types of read-only data files. This only sets the default for some of the following options. The default is PREFIX/share.

* **--datadir=DIRECTORY**

    Sets the directory for read-only data files used by the installed programs. The default is DATAROOTDIR. Note that this has nothing to do with where your database files will be placed.

* **--localedir=DIRECTORY**

    Sets the directory for installing locale data, in particular message translation catalog files. The default is DATAROOTDIR/locale.

* **--mandir=DIRECTORY**

    The man pages that come with PostgreSQL will be installed under this directory, in their respective manx subdirectories. The default is DATAROOTDIR/man.

* **--docdir=DIRECTORY**

    Sets the root directory for installing documentation files, except "man" pages. This only sets the default for the following options. The default value for this option is DATAROOTDIR/doc/postgresql.

* **--htmldir=DIRECTORY**

    The HTML-formatted documentation for PostgreSQL will be installed under this directory. The default is DATAROOTDIR.

    > **Note:** Care has been taken to make it possible to install PostgreSQL into shared installation locations (such as /usr/local/include) without interfering with the namespace of the rest of the system. First, the string "/postgresql" is automatically appended to datadir, sysconfdir, and docdir, unless the fully expanded directory name already contains the string "postgres" or "pgsql". For example, if you choose /usr/local as prefix, the documentation will be installed in /usr/local/doc/postgresql, but if the prefix is /opt/postgres, then it will be in /opt/postgres/doc. The public C header files of the client interfaces are installed into includedir and are namespace-clean. The internal header files and the server header files are installed into private directories under includedir. See the documentation of each interface for information about how to access its header files. Finally, a private subdirectory will also be created, if appropriate, under libdir for dynamically loadable modules.

* **--with-extra-version=STRING**

    Append STRING to the PostgreSQL version number. You can use this, for example, to mark binaries built from unreleased Git snapshots or containing custom patches with an extra version string such as a git describe identifier or a distribution package release number.

* **--with-includes=DIRECTORIES**

    DIRECTORIES is a colon-separated list of directories that will be added to the list the compiler searches for header files. If you have optional packages (such as GNU Readline) installed in a non-standard location, you have to use this option and probably also the corresponding --with-libraries option.

    Example: `--with-includes=/opt/gnu/include:/usr/sup/include`.

* **--with-libraries=DIRECTORIES**

    DIRECTORIES is a colon-separated list of directories to search for libraries. You will probably have to use this option (and the corresponding --with-includes option) if you have packages installed in non-standard locations.

    Example: `--with-libraries=/opt/gnu/lib:/usr/sup/lib`.

* **--enable-nls[=LANGUAGES]**

    Enables Native Language Support (NLS), that is, the ability to display a program's messages in a language other than English. LANGUAGES is an optional space-separated list of codes of the languages that you want supported, for example --enable-nls='de fr'. (The intersection between your list and the set of actually provided translations will be computed automatically.) If you do not specify a list, then all available translations are installed.

    To use this option, you will need an implementation of the Gettext API; see above.

* **--with-pgport=NUMBER**

    Set NUMBER as the default port number for server and clients. The default is 5432. The port can always be changed later on, but if you specify it here then both server and clients will have the same default compiled in, which can be very convenient. Usually the only good reason to select a non-default value is if you intend to run multiple PostgreSQL servers on the same machine.

* **--with-perl**

    Build the PL/Perl server-side language.

* **--with-python**

    Build the PL/Python server-side language.

* **--with-tcl**

    Build the PL/Tcl server-side language.

* **--with-tclconfig=DIRECTORY**

    Tcl installs the file tclConfig.sh, which contains configuration information needed to build modules interfacing to Tcl. This file is normally found automatically at a well-known location, but if you want to use a different version of Tcl you can specify the directory in which to look for it.

* **--with-gssapi**

    Build with support for GSSAPI authentication. On many systems, the GSSAPI (usually a part of the Kerberos installation) system is not installed in a location that is searched by default (e.g., /usr/include, /usr/lib), so you must use the options --with-includes and --with-libraries in addition to this option. configure will check for the required header files and libraries to make sure that your GSSAPI installation is sufficient before proceeding.

* **--with-krb-srvnam=NAME**

    The default name of the Kerberos service principal used by GSSAPI. postgres is the default. There's usually no reason to change this unless you have a Windows environment, in which case it must be set to upper case POSTGRES.

* **--with-openssl**

    Build with support for SSL (encrypted) connections. This requires the OpenSSL package to be installed. configure will check for the required header files and libraries to make sure that your OpenSSL installation is sufficient before proceeding.

* **--with-pam**

    Build with PAM (Pluggable Authentication Modules) support.

* **--with-ldap**

    Build with LDAP support for authentication and connection parameter lookup (see [Section 31.17](http://www.postgresql.org/docs/9.4/interactive/libpq-ldap.html) and [Section 19.3.7](http://www.postgresql.org/docs/9.4/interactive/auth-methods.html#AUTH-LDAP) for more information). On Unix, this requires the OpenLDAP package to be installed. On Windows, the default WinLDAP library is used. configure will check for the required header files and libraries to make sure that your OpenLDAP installation is sufficient before proceeding.

* **--without-readline**

    Prevents use of the Readline library (and libedit as well). This option disables command-line editing and history in psql, so it is not recommended.

* **--with-libedit-preferred**

    Favors the use of the BSD-licensed libedit library rather than GPL-licensed Readline. This option is significant only if you have both libraries installed; the default in that case is to use Readline.

* **--with-bonjour**

    Build with Bonjour support. This requires Bonjour support in your operating system. Recommended on OS X.

* **--with-uuid=LIBRARY**

    Build the [uuid-ossp](http://www.postgresql.org/docs/9.4/interactive/uuid-ossp.html) module (which provides functions to generate UUIDs), using the specified UUID library. LIBRARY must be one of:

    * bsd to use the UUID functions found in FreeBSD, NetBSD, and some other BSD-derived systems
    * e2fs to use the UUID library created by the e2fsprogs project; this library is present in most Linux systems and in OS X, and can be obtained for other platforms as well
    * ossp to use the [OSSP UUID library](http://www.ossp.org/pkg/lib/uuid/)

* **--with-ossp-uuid**

    Obsolete equivalent of --with-uuid=ossp.

* **--with-libxml**

    Build with libxml (enables SQL/XML support). Libxml version 2.6.23 or later is required for this feature.

    Libxml installs a program xml2-config that can be used to detect the required compiler and linker options. PostgreSQL will use it automatically if found. To specify a libxml installation at an unusual location, you can either set the environment variable XML2_CONFIG to point to the xml2-config program belonging to the installation, or use the options --with-includes and --with-libraries.

* **--with-libxslt**

    Use libxslt when building the [xml2](http://www.postgresql.org/docs/9.4/interactive/xml2.html) module. xml2 relies on this library to perform XSL transformations of XML.

* **--disable-integer-datetimes**

    Disable support for 64-bit integer storage for timestamps and intervals, and store datetime values as floating-point numbers instead. Floating-point datetime storage was the default in PostgreSQL releases prior to 8.4, but it is now deprecated, because it does not support microsecond precision for the full range of timestamp values. However, integer-based datetime storage requires a 64-bit integer type. Therefore, this option can be used when no such type is available, or for compatibility with applications written for prior versions of PostgreSQL. See [Section 8.5](http://www.postgresql.org/docs/9.4/interactive/datatype-datetime.html) for more information.

* **--disable-float4-byval**

    Disable passing float4 values "by value", causing them to be passed "by reference" instead. This option costs performance, but may be needed for compatibility with old user-defined functions that are written in C and use the "version 0" calling convention. A better long-term solution is to update any such functions to use the "version 1" calling convention.

* **--disable-float8-byval**

    Disable passing float8 values "by value", causing them to be passed "by reference" instead. This option costs performance, but may be needed for compatibility with old user-defined functions that are written in C and use the "version 0" calling convention. A better long-term solution is to update any such functions to use the "version 1" calling convention. Note that this option affects not only float8, but also int8 and some related types such as timestamp. On 32-bit platforms, --disable-float8-byval is the default and it is not allowed to select --enable-float8-byval.

* **--with-segsize=SEGSIZE**

    Set the segment size, in gigabytes. Large tables are divided into multiple operating-system files, each of size equal to the segment size. This avoids problems with file size limits that exist on many platforms. The default segment size, 1 gigabyte, is safe on all supported platforms. If your operating system has "largefile" support (which most do, nowadays), you can use a larger segment size. This can be helpful to reduce the number of file descriptors consumed when working with very large tables. But be careful not to select a value larger than is supported by your platform and the file systems you intend to use. Other tools you might wish to use, such as tar, could also set limits on the usable file size. It is recommended, though not absolutely required, that this value be a power of 2. Note that changing this value requires an initdb.

* **--with-blocksize=BLOCKSIZE**

    Set the block size, in kilobytes. This is the unit of storage and I/O within tables. The default, 8 kilobytes, is suitable for most situations; but other values may be useful in special cases. The value must be a power of 2 between 1 and 32 (kilobytes). Note that changing this value requires an initdb.

* **--with-wal-segsize=SEGSIZE**

    Set the WAL segment size, in megabytes. This is the size of each individual file in the WAL log. It may be useful to adjust this size to control the granularity of WAL log shipping. The default size is 16 megabytes. The value must be a power of 2 between 1 and 64 (megabytes). Note that changing this value requires an initdb.

* **--with-wal-blocksize=BLOCKSIZE**

    Set the WAL block size, in kilobytes. This is the unit of storage and I/O within the WAL log. The default, 8 kilobytes, is suitable for most situations; but other values may be useful in special cases. The value must be a power of 2 between 1 and 64 (kilobytes). Note that changing this value requires an initdb.

* **--disable-spinlocks**

    Allow the build to succeed even if PostgreSQL has no CPU spinlock support for the platform. The lack of spinlock support will result in poor performance; therefore, this option should only be used if the build aborts and informs you that the platform lacks spinlock support. If this option is required to build PostgreSQL on your platform, please report the problem to the PostgreSQL developers.

* **--disable-thread-safety**

    Disable the thread-safety of client libraries. This prevents concurrent threads in libpq and ECPG programs from safely controlling their private connection handles.

* **--with-system-tzdata=DIRECTORY**

    PostgreSQL includes its own time zone database, which it requires for date and time operations. This time zone database is in fact compatible with the IANA time zone database provided by many operating systems such as FreeBSD, Linux, and Solaris, so it would be redundant to install it again. When this option is used, the system-supplied time zone database in DIRECTORY is used instead of the one included in the PostgreSQL source distribution. DIRECTORY must be specified as an absolute path. /usr/share/zoneinfo is a likely directory on some operating systems. Note that the installation routine will not detect mismatching or erroneous time zone data. If you use this option, you are advised to run the regression tests to verify that the time zone data you have pointed to works correctly with PostgreSQL.

    This option is mainly aimed at binary package distributors who know their target operating system well. The main advantage of using this option is that the PostgreSQL package won't need to be upgraded whenever any of the many local daylight-saving time rules change. Another advantage is that PostgreSQL can be cross-compiled more straightforwardly if the time zone database files do not need to be built during the installation.

* **--without-zlib**

    Prevents use of the Zlib library. This disables support for compressed archives in pg_dump and pg_restore. This option is only intended for those rare systems where this library is not available.

* **--enable-debug**

    Compiles all programs and libraries with debugging symbols. This means that you can run the programs in a debugger to analyze problems. This enlarges the size of the installed executables considerably, and on non-GCC compilers it usually also disables compiler optimization, causing slowdowns. However, having the symbols available is extremely helpful for dealing with any problems that might arise. Currently, this option is recommended for production installations only if you use GCC. But you should always have it on if you are doing development work or running a beta version.

* **--enable-coverage**

    If using GCC, all programs and libraries are compiled with code coverage testing instrumentation. When run, they generate files in the build directory with code coverage metrics. See [Section 30.5](http://www.postgresql.org/docs/9.4/interactive/regress-coverage.html) for more information. This option is for use only with GCC and when doing development work.

* **--enable-profiling**

    If using GCC, all programs and libraries are compiled so they can be profiled. On backend exit, a subdirectory will be created that contains the gmon.out file for use in profiling. This option is for use only with GCC and when doing development work.

* **--enable-cassert**

    Enables assertion checks in the server, which test for many "cannot happen" conditions. This is invaluable for code development purposes, but the tests can slow down the server significantly. Also, having the tests turned on won't necessarily enhance the stability of your server! The assertion checks are not categorized for severity, and so what might be a relatively harmless bug will still lead to server restarts if it triggers an assertion failure. This option is not recommended for production use, but you should have it on for development work or when running a beta version.

* **--enable-depend**

    Enables automatic dependency tracking. With this option, the makefiles are set up so that all affected object files will be rebuilt when any header file is changed. This is useful if you are doing development work, but is just wasted overhead if you intend only to compile once and install. At present, this option only works with GCC.

* **--enable-dtrace**

    Compiles PostgreSQL with support for the dynamic tracing tool DTrace. See [Section 27.4](http://www.postgresql.org/docs/9.4/interactive/dynamic-trace.html) for more information.

    To point to the dtrace program, the environment variable DTRACE can be set. This will often be necessary because dtrace is typically installed under /usr/sbin, which might not be in the path.

    Extra command-line options for the dtrace program can be specified in the environment variable DTRACEFLAGS. On Solaris, to include DTrace support in a 64-bit binary, you must specify DTRACEFLAGS="-64" to configure. For example, using the GCC compiler:

    ```bash
    ./configure CC='gcc -m64' --enable-dtrace DTRACEFLAGS='-64' ...
    ```

    Using Sun's compiler:

    ```bash
    ./configure CC='/opt/SUNWspro/bin/cc -xtarget=native64' --enable-dtrace DTRACEFLAGS='-64' ...
    ```

* **--enable-tap-tests**

    Enable tests using the Perl TAP tools. This requires a Perl installation and the Perl module IPC::Run. See [Section 30.4](http://www.postgresql.org/docs/9.4/interactive/regress-tap.html) for more information.

If you prefer a C compiler different from the one configure picks, you can set the environment variable CC to the program of your choice. By default, configure will pick gcc if available, else the platform's default (usually cc). Similarly, you can override the default compiler flags if needed with the CFLAGS variable.

You can specify environment variables on the configure command line, for example:

```bash
./configure CC=/opt/bin/gcc CFLAGS='-O2 -pipe'
```

Here is a list of the significant variables that can be set in this manner:

* BISON

    Bison program

* CC

    C compiler

* CFLAGS

    options to pass to the C compiler

* CPP

    C preprocessor

* CPPFLAGS

    options to pass to the C preprocessor

* DTRACE

    location of the dtrace program

* DTRACEFLAGS

    options to pass to the dtrace program

* FLEX

    Flex program

* LDFLAGS

    options to use when linking either executables or shared libraries

* LDFLAGS_EX

    additional options for linking executables only

* LDFLAGS_SL

    additional options for linking shared libraries only

* MSGFMT

    msgfmt program for native language support

* PERL

    Full path to the Perl interpreter. This will be used to determine the dependencies for building PL/Perl.

* PYTHON

    Full path to the Python interpreter. This will be used to determine the dependencies for building PL/Python. Also, whether Python 2 or 3 is specified here (or otherwise implicitly chosen) determines which variant of the PL/Python language becomes available. See Section 43.1 for more information.

* TCLSH

    Full path to the Tcl interpreter. This will be used to determine the dependencies for building PL/Tcl, and it will be substituted into Tcl scripts.

* XML2_CONFIG

    xml2-config program used to locate the libxml installation.

    > Note: When developing code inside the server, it is recommended to use the configure options --enable-cassert (which turns on many run-time error checks) and --enable-debug (which improves the usefulness of debugging tools).
    >
    > If using GCC, it is best to build with an optimization level of at least -O1, because using no optimization (-O0) disables some important compiler warnings (such as the use of uninitialized variables). However, non-zero optimization levels can complicate debugging because stepping through compiled code will usually not match up one-to-one with source code lines. If you get confused while trying to debug optimized code, recompile the specific files of interest with -O0. An easy way to do this is by passing an option to make: make PROFILE=-O0 file.o.

###Build

To start the build, type:

```
make
```

(Remember to use GNU make.) The build will take a few minutes depending on your hardware. The last line displayed should be:

```
All of PostgreSQL is successfully made. Ready to install.
```

If you want to build everything that can be built, including the documentation (HTML and man pages), and the additional modules (contrib), type instead:

```
make world
```

The last line displayed should be:

```
PostgreSQL, contrib and HTML documentation successfully made. Ready to install.
```

###Regression Tests

If you want to test the newly built server before you install it, you can run the regression tests at this point. The regression tests are a test suite to verify that PostgreSQL runs on your machine in the way the developers expected it to. Type:

```
make check
```

(This won't work as root; do it as an unprivileged user.) [Chapter 30](http://www.postgresql.org/docs/9.4/interactive/regress.html) contains detailed information about interpreting the test results. You can repeat this test at any later time by issuing the same command.

###Installing the Files

> Note: If you are upgrading an existing system be sure to read Section 17.6 which has instructions about upgrading a cluster.

To install PostgreSQL enter:

```
make install
```

This will install files into the directories that were specified in step 1. Make sure that you have appropriate permissions to write into that area. Normally you need to do this step as root. Alternatively, you can create the target directories in advance and arrange for appropriate permissions to be granted.

To install the documentation (HTML and man pages), enter:

```
make install-docs
```

If you built the world above, type instead:

```
make install-world
```

This also installs the documentation.

You can use make install-strip instead of make install to strip the executable files and libraries as they are installed. This will save some space. If you built with debugging support, stripping will effectively remove the debugging support, so it should only be done if debugging is no longer needed. install-strip tries to do a reasonable job saving space, but it does not have perfect knowledge of how to strip every unneeded byte from an executable file, so if you want to save all the disk space you possibly can, you will have to do manual work.

The standard installation provides all the header files needed for client application development as well as for server-side program development, such as custom functions or data types written in C. (Prior to PostgreSQL 8.0, a separate make install-all-headers command was needed for the latter, but this step has been folded into the standard install.)

####Client-only installation

If you want to install only the client applications and interface libraries, then you can use these commands:

```bash
make -C src/bin install
make -C src/include install
make -C src/interfaces install
make -C doc install
```

src/bin has a few binaries for server-only use, but they are small.

####Uninstallation

To undo the installation use the command make uninstall. However, this will not remove any created directories.

####Cleaning

After the installation you can free disk space by removing the built files from the source tree with the command make clean. This will preserve the files made by the configure program, so that you can rebuild everything with make later on. To reset the source tree to the state in which it was distributed, use make distclean. If you are going to build for several platforms within the same source tree you must do this and re-configure for each platform. (Alternatively, use a separate build tree for each platform, so that the source tree remains unmodified.)

> If you perform a build and then discover that your configure options were wrong, or if you change anything that configure investigates (for example, software upgrades), then it's a good idea to do make distclean before reconfiguring and rebuilding. Without this, your changes in configuration choices might not propagate everywhere they need to.

###Post-Installation Setup

####Shared Libraries

On some systems with shared libraries you need to tell the system how to find the newly installed shared libraries. The systems on which this is not necessary include FreeBSD, HP-UX, Linux, NetBSD, OpenBSD, Tru64 UNIX (formerly Digital UNIX), and Solaris.

The method to set the shared library search path varies between platforms, but the most widely-used method is to set the environment variable LD_LIBRARY_PATH like so: In Bourne shells (sh, ksh, bash, zsh):

```bash
LD_LIBRARY_PATH=/usr/local/pgsql/lib
export LD_LIBRARY_PATH
```

or in csh or tcsh:

```csh
setenv LD_LIBRARY_PATH /usr/local/pgsql/lib
```

Replace /usr/local/pgsql/lib with whatever you set --libdir to in [step 1](http://www.postgresql.org/docs/9.4/interactive/install-procedure.html#CONFIGURE). You should put these commands into a shell start-up file such as /etc/profile or ~/.bash_profile. Some good information about the caveats associated with this method can be found at http://xahlee.org/UnixResource_dir/_/ldpath.html.

On some systems it might be preferable to set the environment variable LD_RUN_PATH before building.

On Cygwin, put the library directory in the PATH or move the .dll files into the bin directory.

If in doubt, refer to the manual pages of your system (perhaps ld.so or rld). If you later get a message like:

```
psql: error in loading shared libraries
libpq.so.2.1: cannot open shared object file: No such file or directory
```

then this step was necessary. Simply take care of it then.

If you are on Linux and you have root access, you can run:

```bash
/sbin/ldconfig /usr/local/pgsql/lib
```

(or equivalent directory) after installation to enable the run-time linker to find the shared libraries faster. Refer to the manual page of ldconfig for more information. On FreeBSD, NetBSD, and OpenBSD the command is:

```bash
/sbin/ldconfig -m /usr/local/pgsql/lib
```

instead. Other systems are not known to have an equivalent command.

####Environment Variables

If you installed into /usr/local/pgsql or some other location that is not searched for programs by default, you should add /usr/local/pgsql/bin (or whatever you set --bindir to in [step 1](http://www.postgresql.org/docs/9.4/interactive/install-procedure.html#CONFIGURE)) into your PATH. Strictly speaking, this is not necessary, but it will make the use of PostgreSQL much more convenient.

To do this, add the following to your shell start-up file, such as ~/.bash_profile (or /etc/profile, if you want it to affect all users):

```bash
PATH=/usr/local/pgsql/bin:$PATH
export PATH
```

If you are using csh or tcsh, then use this command:

```csh
set path = ( /usr/local/pgsql/bin $path )
```

To enable your system to find the man documentation, you need to add lines like the following to a shell start-up file unless you installed into a location that is searched by default:

```bash
MANPATH=/usr/local/pgsql/man:$MANPATH
export MANPATH
```

The environment variables PGHOST and PGPORT specify to client applications the host and port of the database server, overriding the compiled-in defaults. If you are going to run client applications remotely then it is convenient if every user that plans to use the database sets PGHOST. This is not required, however; the settings can be communicated via command line options to most client programs.

##Reference

* [1] [Short Version](http://www.postgresql.org/docs/9.4/interactive/install-short.html)
* [2] [Requirements](http://www.postgresql.org/docs/9.4/interactive/install-requirements.html)
* [3] [Getting The Source](http://www.postgresql.org/docs/9.4/interactive/install-getsource.html)
* [4] [Installation Procedure](http://www.postgresql.org/docs/9.4/interactive/install-procedure.html)
* [5] [Post-Installation Setup](http://www.postgresql.org/docs/9.4/interactive/install-post.html)