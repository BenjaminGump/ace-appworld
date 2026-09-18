@echo off
setlocal
cd /d "%~dp0"

if not defined DEEPSEEK_API_KEY (
    echo ERROR: DEEPSEEK_API_KEY is not set.
    echo Run: set "DEEPSEEK_API_KEY=YOUR_KEY"
    exit /b 1
)

set "DEEPSEEK_API_BASE=https://api.deepseek.com/v1"
set "APPWORLD_PROJECT_PATH=%CD%"
set "APPWORLD_ROOT=%CD%"
set "PYTHONUTF8=1"

echo Running ACE offline adaptation with DeepSeek...
appworld run ACE_offline_no_GT_adaptation

endlocal
