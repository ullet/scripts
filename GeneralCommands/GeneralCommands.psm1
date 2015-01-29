<#
.SYNOPSIS
  Sets current location to the previously saved location.
.DESCRIPTION
  Sets current location to the previously saved location.
  Location path is stored in process environment variable:
    GeneralCommandsSwitchLocationPrevious
  Returns the location object (System.Management.Automation.PathInfo)
  for the restored location.
#>
function Restore-Location {
  $location = getSavedLocation
  if ($location -ne $null)
  {
    Set-Location $location
  }
  return Get-Location
}

<#
.SYNOPSIS
  Saves the current location then sets current location to either
  the previously saved location or the specified location.
.DESCRIPTION
  Saves the current location then sets current location to either
  the previously saved location or the specified location.
  Location path is stored in the process environment variable:
    GeneralCommandsSwitchLocationPrevious
  Returns the location object (System.Management.Automation.PathInfo).
.PARAMETER Location
  Optional location to switch to. If not specified will attempt to
  switch to the previously saved location. If no previously saved
  location will stay in current directory and result will be same as
  if called Save-Location.
.PARAMETER Create
  Optional switch. If set will attempt to to create the directory
  structure for the specified or saved location if does not already
  exist. If not set and location switching to does not exist then an
  exception will be thrown.
#>
function Switch-Location {
param (
  $location,
  [switch]$create
)
  if ($location -eq $null)
  {
    $location = getSavedLocation
  }
  if ($location -eq $null)
  {
    $location = Get-Location
  }
  if ($create -and !(Test-Path $location))
  {
    New-Item -ItemType Container $location | Out-Null
  }
  $currentLocation = Save-Location
  Set-Location $location
  return $currentLocation
}

<#
.SYNOPSIS
  Saves current location to a process environment variable for 
  later retrieval.
.DESCRIPTION
  Saves current location to a process environment variable for 
  later retrieval.
  Location path is saved to process environment variable:
    GeneralCommandsSwitchLocationPrevious
  Returns the location object (System.Management.Automation.PathInfo)
  for the saved location.
#>
function Save-Location {
  $currentLocation = Get-Location
  [Environment]::SetEnvironmentVariable(
    "GeneralCommandsSwitchLocationPrevious", $currentLocation, "Process")
  return $currentLocation
}  

function getSavedLocation {
  [Environment]::GetEnvironmentVariable(
      "GeneralCommandsSwitchLocationPrevious", "Process")
}

Export-ModuleMember Restore-Location, Save-Location, Switch-Location
