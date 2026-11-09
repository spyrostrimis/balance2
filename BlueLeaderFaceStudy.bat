@echo off
setlocal
if not defined GODOT_EXE set "GODOT_EXE=C:\Godot\Godot_v4.7.2-stable_win64.exe"
start "Balance Leader Anatomy" "%GODOT_EXE%" --path "%~dp0." --rendering-method forward_plus res://scenes/blue_leader_face_study.tscn
