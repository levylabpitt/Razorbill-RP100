@echo off
setlocal EnableDelayedExpansion

REM Ensure we're in the repository root (where this script lives)
cd /d "%~dp0"

REM Arguments passed from Patrick Builder
set "VERSION=2.2.3.16"
set "TITLE=Razorbill RP100 2.2.3.16"
set "NOTES=[2.2.3]
- build with pgsql/3.12.1.15 (hotfix for connection key)"

set "VIPB_FILE=C:\Users\patrick\Documents\GitHub\levylabpitt\Razorbill-RP100\build support\Razorbill RP100.vipb"

set LVVER=2019
set LVBIT=64

echo ======================================
echo Building %TITLE%
echo ======================================

REM Git flow start
echo Starting release %VERSION%...
git flow release start %VERSION%
if %ERRORLEVEL% neq 0 (
    echo ERROR: git flow release start failed
    exit /b 1
)

REM Clean staging area
echo Cleaning builds\latest staging area...
if exist "builds\latest" (
    del /Q "builds\latest\*.*"
) else (
    mkdir "builds\latest"
)

REM Build VIP
echo Building VIP...
g-cli --lv-ver %LVVER% --arch %LVBIT% vipBuild -- "%VIPB_FILE%"
if %ERRORLEVEL% neq 0 (
    echo ERROR: VIP build failed
    exit /b 1
)

REM Execute generated launcher script (builds exe/installer/7z)
echo Building executables and installers...
call "builds\7z Install\7zip.bat"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Executable build failed
    exit /b 1
)

REM Git flow finish
echo Committing changes...
git commit -m "Build %VERSION%" -a
if %ERRORLEVEL% neq 0 (
    echo ERROR: git commit failed
    exit /b 1
)

echo Finishing release %VERSION%...
git flow release finish %VERSION% -m "Build %VERSION%"
if %ERRORLEVEL% neq 0 (
    echo ERROR: git flow release finish failed
    exit /b 1
)

git reset --hard
if %ERRORLEVEL% neq 0 (
    echo ERROR: git reset failed
    exit /b 1
)

echo Pushing to remote...
git push --all
if %ERRORLEVEL% neq 0 (
    echo ERROR: git push --all failed
    exit /b 1
)

git push --tags
if %ERRORLEVEL% neq 0 (
    echo ERROR: git push --tags failed
    exit /b 1
)

REM GitHub release
echo Creating GitHub release %VERSION%...
set ASSETS=
for %%F in (builds\latest\*.vip builds\latest\*.exe) do (
    set ASSETS=!ASSETS! "%%F"
)
gh release create %VERSION% !ASSETS! -t "%TITLE%" -n "%NOTES%"
if %ERRORLEVEL% neq 0 (
    echo ERROR: GitHub release creation failed
    exit /b 1
)

echo.
echo ======================================
echo Build %VERSION% completed successfully
echo ======================================
exit /b 0