@chcp 65001
@cd /d %~dp0

:: 设置Qt版本
SET QT_VERSION=6.12.0

:: 设置MSVC版本代号
SET MSVC_VERSION=msvc2022_64

:: 设置MSVC2022环境
CALL "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" amd64

:: 设置Ninja (已注释，使用GitHub Actions自带的Ninja)
:: SET PATH=D:\a\buildQt\ninja;%PATH%

:: 设置Qt文件夹路径
SET QT_PATH=D:\a\buildQt\Qt

::----------以下无需修改----------

:: 设置Qt源代码目录
SET SRC_QT="%QT_PATH%\%QT_VERSION%\qt-everywhere-src-%QT_VERSION%"

:: 设置安装文件夹目录
SET INSTALL_DIR="%QT_PATH%\%QT_VERSION%-shared\%MSVC_VERSION%"

:: 设置build文件夹目录
SET BUILD_DIR="%QT_PATH%\%QT_VERSION%\build-%MSVC_VERSION%"

:: 根据需要进行全新构建 (优化：先判断是否存在)
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"

:: 定位到构建目录：
mkdir "%BUILD_DIR%" && cd /d "%BUILD_DIR%"

:: configure (构建 shared 且同时包含 Debug 和 Release)
call %SRC_QT%\configure.bat -shared -debug-and-release -G "Ninja Multi-Config" -prefix %INSTALL_DIR% -nomake examples -nomake tests -skip qtwebengine -opensource -confirm-license -qt-libpng -qt-libjpeg -qt-zlib -qt-pcre -qt-freetype -qt-harfbuzz -qt-webp -qt-tiff -schannel -opengl desktop -platform win32-msvc

:: 分别编译 Release 和 Debug
cmake --build . --config Release --parallel
cmake --build . --config Debug --parallel

:: 分别安装 Release 和 Debug
cmake --install . --config Release
cmake --install . --config Debug

::复制qt.conf
copy %~dp0\qt.conf %INSTALL_DIR%\bin

::@pause
:: @cmd /k cd /d %INSTALL_DIR%
