@ECHO OFF
SET ZLIB_VERSION=1.2.11
SET BZIP2_VERSION=b7a672291188a6469f71dd13ad14f2f9a7344fc8
SET XZ_VERSION=5.2.5
SET ZSTD_VERSION=1.5.2
IF NOT "%BE%"=="mingw-gcc" (
  IF NOT "%BE%"=="msvc" (
    ECHO Environment variable BE must be mingw-gcc or msvc
    EXIT /b 1
  )
)

SET ORIGPATH=%PATH%
IF "%BE%"=="mingw-gcc" (
  SET MINGWPATH=C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\Program Files\cmake\bin;C:\ProgramData\chocolatey\lib\mingw\tools\install\mingw64\bin
)

IF "%1"=="deplibs" (
  IF NOT EXIST build_ci\libs (
    MKDIR build_ci\libs
  )
  CD build_ci\libs
rem   IF NOT EXIST zlib-%ZLIB_VERSION%.zip (
rem     ECHO Downloading https://github.com/libarchive/zlib/archive/v%ZLIB_VERSION%.zip
rem     curl -L -o zlib-%ZLIB_VERSION%.zip https://github.com/libarchive/zlib/archive/v%ZLIB_VERSION%.zip || EXIT /b 1
rem   )
rem   IF NOT EXIST zlib-%ZLIB_VERSION% (
rem     ECHO Unpacking zlib-%ZLIB_VERSION%.zip
rem     C:\windows\system32\tar.exe -x -f zlib-%ZLIB_VERSION%.zip || EXIT /b 1
rem   )
rem   IF NOT EXIST bzip2-%BZIP2_VERSION%.zip (
rem     echo Downloading https://github.com/libarchive/bzip2/archive/%BZIP2_VERSION%.zip
rem     curl -L -o bzip2-%BZIP2_VERSION%.zip https://github.com/libarchive/bzip2/archive/%BZIP2_VERSION%.zip || EXIT /b 1
rem   )
rem   IF NOT EXIST bzip2-%BZIP2_VERSION% (
rem     echo Unpacking bzip2-%BZIP2_VERSION%.zip
rem     C:\windows\system32\tar.exe -x -f bzip2-%BZIP2_VERSION%.zip || EXIT /b 1
rem   )
rem   IF NOT EXIST xz-%XZ_VERSION%.zip (
rem     echo Downloading https://github.com/libarchive/xz/archive/%XZ_VERSION%.zip
rem     curl -L -o xz-%XZ_VERSION%.zip https://github.com/libarchive/xz/archive/v%XZ_VERSION%.zip || EXIT /b 1
rem   )
rem   IF NOT EXIST xz-%XZ_VERSION% (
rem     echo Unpacking xz-%XZ_VERSION%.zip
rem     C:\windows\system32\tar.exe -x -f xz-%XZ_VERSION%.zip || EXIT /b 1
rem   )
  IF NOT EXIST zstd-%ZSTD_VERSION%.tar.gz (
    echo Downloading https://github.com/facebook/zstd/archive/refs/tags/v%ZSTD_VERSION%.tar.gz
    curl -L -o zstd-%ZSTD_VERSION%.tar.gz https://github.com/facebook/zstd/archive/refs/tags/v%ZSTD_VERSION%.tar.gz || EXIT /b 1
  )
  IF NOT EXIST zstd-%ZSTD_VERSION% (
    echo Unpacking zstd-%ZSTD_VERSION%.tar.gz
    C:\windows\system32\tar.exe -x -f zstd-%ZSTD_VERSION%.tar.gz || EXIT /b 1
  )
rem  CD zlib-%ZLIB_VERSION%
rem  IF "%BE%"=="mingw-gcc" (
rem    SET PATH=%MINGWPATH%
rem    cmake -G "MinGW Makefiles" -D CMAKE_BUILD_TYPE="Release" . || EXIT /b 1
rem    mingw32-make || EXIT /b 1
rem    mingw32-make test || EXIT /b 1
rem    mingw32-make install || EXIT /b 1
rem  ) ELSE IF "%BE%"=="msvc" (
rem    cmake -G "Visual Studio 17 2022" . || EXIT /b 1
rem    cmake --build . --target ALL_BUILD --config Release || EXIT /b 1
rem    cmake --build . --target RUN_TESTS --config Release || EXIT /b 1
rem    cmake --build . --target INSTALL --config Release || EXIT /b 1
rem  )
rem  CD ..
rem  CD bzip2-%BZIP2_VERSION%
rem  IF "%BE%"=="mingw-gcc" (
rem    SET PATH=%MINGWPATH%
rem    cmake -G "MinGW Makefiles" -D CMAKE_BUILD_TYPE="Release" -D ENABLE_LIB_ONLY=ON -D ENABLE_SHARED_LIB=OFF -D ENABLE_STATIC_LIB=ON . || EXIT /b 1
rem    mingw32-make || EXIT /b 1
rem    REM mingw32-make test || EXIT /b 1
rem    mingw32-make install || EXIT /b 1
rem  ) ELSE IF "%BE%"=="msvc" (
rem    cmake -G "Visual Studio 17 2022" -D CMAKE_BUILD_TYPE="Release" -D ENABLE_LIB_ONLY=ON -D ENABLE_SHARED_LIB=OFF -D ENABLE_STATIC_LIB=ON . || EXIT /b 1
rem    cmake --build . --target ALL_BUILD --config Release || EXIT /b 1
rem    REM cmake --build . --target RUN_TESTS --config Release || EXIT /b 1
rem    cmake --build . --target INSTALL --config Release || EXIT /b 1
rem  )
rem  CD ..
rem  CD xz-%XZ_VERSION%
rem  IF "%BE%"=="mingw-gcc" (
rem    SET PATH=%MINGWPATH%
rem    cmake -G "MinGW Makefiles" -D CMAKE_BUILD_TYPE="Release" . || EXIT /b 1
rem    mingw32-make || EXIT /b 1
rem    mingw32-make install || EXIT /b 1
rem  ) ELSE IF "%BE%"=="msvc" (
rem    cmake -G "Visual Studio 17 2022" -D CMAKE_BUILD_TYPE="Release" . || EXIT /b 1
rem    cmake --build . --target ALL_BUILD --config Release || EXIT /b 1
rem    cmake --build . --target INSTALL --config Release || EXIT /b 1
rem  )
  CD zstd-%ZSTD_VERSION%
  IF "%BE%"=="mingw-gcc" (
    SET PATH=%MINGWPATH%
    cmake -G "MinGW Makefiles" -D CMAKE_BUILD_TYPE="Release" . || EXIT /b 1
    mingw32-make || EXIT /b 1
    mingw32-make install || EXIT /b 1
  ) ELSE IF "%BE%"=="msvc" (
    cmake -G "Visual Studio 17 2022" -D CMAKE_BUILD_TYPE="Release" . || EXIT /b 1
    cmake --build . --target ALL_BUILD --config Release || EXIT /b 1
    cmake --build . --target INSTALL --config Release || EXIT /b 1
  )
) ELSE IF "%1%"=="configure" (
  IF "%BE%"=="mingw-gcc" (
    SET PATH=%MINGWPATH%
    MKDIR build_ci\cmake
    CD build_ci\cmake
    cmake -G "MinGW Makefiles" -D ZLIB_LIBRARY="C:/Program Files (x86)/zlib/lib/libzlibstatic.a" -D ZLIB_INCLUDE_DIR="C:/Program Files (x86)/zlib/include" -D BZIP2_LIBRARIES="C:/Program Files (x86)/bzip2/lib/libbz2.a" -D BZIP2_INCLUDE_DIR="C:/Program Files (x86)/bzip2/include" -D LIBLZMA_LIBRARY="C:/Program Files (x86)/xz/lib/liblzma.a" -D LIBLZMA_INCLUDE_DIR="C:/Program Files (x86)/xz/include" ..\.. || EXIT /b 1
  ) ELSE IF "%BE%"=="msvc" (
    MKDIR build_ci\cmake
    CD build_ci\cmake
    cmake -G "Visual Studio 17 2022" -D CMAKE_BUILD_TYPE="Release" -D ZLIB_LIBRARY="C:/Program Files (x86)/zlib/lib/zlibstatic.lib" -D ZLIB_INCLUDE_DIR="C:/Program Files (x86)/zlib/include" -D BZIP2_LIBRARIES="C:/Program Files (x86)/bzip2/lib/bz2.lib" -D BZIP2_INCLUDE_DIR="C:/Program Files (x86)/bzip2/include" -D LIBLZMA_LIBRARY="C:/Program Files (x86)/xz/lib/liblzma.lib" -D LIBLZMA_INCLUDE_DIR="C:/Program Files (x86)/xz/include" ..\.. || EXIT /b 1
  )
) ELSE IF "%1%"=="build" (
  IF "%BE%"=="mingw-gcc" (
    SET PATH=%MINGWPATH%
    CD build_ci\cmake
    mingw32-make VERBOSE=1 || EXIT /b 1
  ) ELSE IF "%BE%"=="msvc" (
    CD build_ci\cmake
    cmake --build . --target ALL_BUILD --config Release || EXIT /b 1
  )
) ELSE IF "%1%"=="test" (
  IF "%BE%"=="mingw-gcc" (
    SET PATH=%MINGWPATH%
    CD build_ci\cmake
    SET SKIP_TEST_SPARSE=1
    mingw32-make test VERBOSE=1 || EXIT /b 1
  ) ELSE IF "%BE%"=="msvc" (
    ECHO "Skipping tests on this platform"
    EXIT /b 0
    REM CD build_ci\cmake
    REM cmake --build . --target RUN_TESTS --config Release || EXIT /b 1
  )
) ELSE IF "%1%"=="install" (
  IF "%BE%"=="mingw-gcc" (
    SET PATH=%MINGWPATH%
    CD build_ci\cmake
    mingw32-make install || EXIT /b 1
  ) ELSE IF "%BE%"=="msvc" (
    CD build_ci\cmake
    cmake --build . --target INSTALL --config Release || EXIT /b 1
  )
) ELSE IF "%1"=="artifact" (
    C:\windows\system32\tar.exe -c -C "C:\Program Files (x86)" --format=zip -f libarchive.zip libarchive
) ELSE (
  ECHO "Usage: %0% deplibs|configure|build|test|install|artifact"
  @EXIT /b 0
)
@EXIT /b 0
