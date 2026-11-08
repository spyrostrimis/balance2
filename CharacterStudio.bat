@echo off
setlocal
if defined GODOT_EXE goto launch
set "GODOT_EXE=C:\Godot\Godot_v4.7.2-stable_win64.exe"
:launch
if not exist "%GODOT_EXE%" (
  echo Open scenes/character_studio.tscn in Godot 4.7.2 and press F6,
  echo or set GODOT_EXE to your Godot executable.
  pause
  exit /b 1
)
start "Balance Character Studio" "%GODOT_EXE%" --path "%~dp0." res://scenes/character_studio.tscn
