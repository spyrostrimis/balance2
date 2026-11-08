@echo off
setlocal
if defined GODOT_EXE goto launch
set "GODOT_EXE=C:\Godot\Godot_v4.7.2-stable_win64.exe"
:launch
if not exist "%GODOT_EXE%" (
  echo Godot was not found. Open project.godot in Godot 4.7.2,
  echo or set GODOT_EXE to your Godot executable.
  pause
  exit /b 1
)
start "Balance" "%GODOT_EXE%" --path "%~dp0."
