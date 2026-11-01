@echo off
chcp 65001 > nul
title Data Pipeline Orchestrator - Capstone Project
echo ======================================================================
echo    KHOI DONG PIPELINE NAP DU LIEU (4 TASKS)
echo ======================================================================
echo.
python "%~dp0run_all.py"
echo.
pause
