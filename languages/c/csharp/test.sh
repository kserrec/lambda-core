#!/bin/sh
set -eu

command -v dotnet >/dev/null 2>&1 || exit 42

directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_directory=$(mktemp -d)
trap 'rm -rf "$build_directory"' EXIT HUP INT TERM

export DOTNET_CLI_HOME="$build_directory/dotnet-home"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_NOLOGO=1
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
export NUGET_PACKAGES="$build_directory/nuget-packages"

dotnet build \
    "$directory/LambdaCore.csproj" \
    --configuration Release \
    --nologo \
    --verbosity quiet \
    --property:BaseOutputPath="$build_directory/bin/" \
    --property:BaseIntermediateOutputPath="$build_directory/obj/" \
    1>&2

dotnet "$build_directory/bin/Release/net8.0/LambdaCore.dll"
