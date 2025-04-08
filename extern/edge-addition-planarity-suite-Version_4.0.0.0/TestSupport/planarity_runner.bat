@echo off

REM Change to correspond to the location of the planarity executable
SET planarityPath="C:\Users\wbkbo\git\edge-addition-planarity-suite-fork\Release\planarity.exe"

REM Change to correspond to the parent of the test files directory
SET graphFilesDir="E:\graphs"

REM Change to correspond to the root output directory
SET outputDir="C:\Users\wbkbo\git\edge-addition-planarity-suite-fork\TestSupport\results"

SET /A N=11
SET C=p
IF NOT "%1"=="" (
    SET N=%1
    IF NOT "%2"=="" (
        SET C=%2
    )
)

IF NOT EXIST "%outputDir%\%N%\%C%" mkdir "%outputDir%\%N%\%C%"

SET /A MAXM = (%N% * (%N% - 1^)) / 2

FOR /L %%M IN (0,1,%MAXM%) DO (
    CALL %planarityPath% -t -%C% "%graphFilesDir%\%N%\test.n%N%.m%%M.g6" "%outputDir%\%N%\%C%\n%N%.m%%M.%C%.out.txt"
)
