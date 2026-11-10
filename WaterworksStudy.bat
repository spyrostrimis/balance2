@echo off
setlocal
if not defined GODOT_EXE set "GODOT_EXE=C:\Godot\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT_EXE%" (
  echo Set GODOT_EXE to your Godot 4.7.2 executable.
  pause
  exit /b 1
)
start "Balance Waterworks Study" "%GODOT_EXE%" --path "%~dp0." --rendering-method gl_compatibility res://scenes/waterworks_study.tscn
