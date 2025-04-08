@echo off
REM Change to correspond to the location of the geng executable
SET gengPath="C:\Users\wbkbo\git\nauty\geng.exe"

REM Change to correspond to the root output directory
SET graphOutputDir="E:\graphs"

SET /A N=11
IF NOT "%1"=="" (
    SET N=%1
)

SET /A MAXM = (%N% * (%N% - 1^)) / 2

IF NOT EXIST "%graphOutputDir%\%N%" mkdir "%graphOutputDir%\%N%"

REM Make sure to update the path to the geng executable and the directory to which you wish to write the generated graphs
FOR /L %%M IN (0,1,%MAXM%) DO (
    START /B "geng%%M" %gengPath% %N% %%M:%%M > "%graphOutputDir%\%N%\n%N%.m%%M.g6"
)
