@echo off
title MovieBox Mobile - APK Builder
echo ========================================================
echo         MovieBox Mobile - Automatic APK Builder
echo ========================================================
echo.

echo [1/3] Checking Flutter installation...
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter SDK is not installed or not added to PATH!
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install/windows
    echo Or use Method 2 (GitHub Actions) to build online for free without installing anything!
    echo.
    pause
    exit /b
)

echo Flutter detected successfully!
echo.
echo [2/3] Fetching dependencies (flutter pub get)...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to fetch packages. Please check your internet connection.
    pause
    exit /b
)

echo.
echo [3/3] Building Release APK (This may take 2-5 minutes)...
call flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] APK build failed. Check error log above.
    pause
    exit /b
)

echo.
echo ========================================================
echo [SUCCESS] APK BUILD COMPLETED!
echo ========================================================
echo.
echo Your APK file is ready at:
echo %~dp0build\app\outputs\flutter-apk\app-release.apk
echo.
echo You can copy this file to your Android phone and install it!
echo.
pause
