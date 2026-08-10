# DOTNET_NOLOGO / telemetry opt-out keep the first-run banner off stdout so the
# captured output is just the program's.
DOTNET_NOLOGO=1 DOTNET_CLI_TELEMETRY_OPTOUT=1 dotnet fsi lambda-core.fsx
