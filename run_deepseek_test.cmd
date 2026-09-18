@echo off
setlocal
cd /d "%~dp0"

if not defined DEEPSEEK_API_KEY (
    echo ERROR: DEEPSEEK_API_KEY is not set.
    echo Run: set "DEEPSEEK_API_KEY=YOUR_KEY"
    exit /b 1
)

if not exist experiments\playbooks\appworld_final_playbook.txt (
    echo ERROR: trained appworld_final_playbook.txt not found.
    exit /b 1
)

set "DEEPSEEK_API_BASE=https://api.deepseek.com/v1"
set "APPWORLD_PROJECT_PATH=%CD%"
set "APPWORLD_ROOT=%CD%"
set "PYTHONUTF8=1"

echo Running ACE evaluation on test_normal...
appworld run ACE_offline_no_GT_evaluation
if errorlevel 1 exit /b 1

echo Computing test_normal metrics...
appworld evaluate ACE_offline_no_GT_evaluation test_normal
if errorlevel 1 exit /b 1

endlocal
