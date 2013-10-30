@IF EXIST "%~dp0\node_modules\.bin\node.exe" (
  "%~dp0\node_modules\.bin\node.exe"  "%~dp0\node_modules\coffee-script\bin\coffee" score.coffee %*
) ELSE (
  node  "%~dp0\node_modules\coffee-script\bin\coffee" score.coffee %*
)
