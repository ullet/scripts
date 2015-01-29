Import-Module GeneralCommands

function New-TfsCloak {
param(
  [string]$serverPath,
  [string]$workspaceName = "",
  [string]$collectionUrl = ""
)
  $collectionParameter = getCollectionParameter $collectionUrl
  $workspaceParameter = getWorkspaceParameter $workspaceName
  executeTfsCommand `
    'workfold' 'cloak' ($serverPath, $workspaceParameter, $collectionParameter)
}

function New-TfsWorkFolderMapping {
param(
  [string]$workspaceName,
  [string]$serverPath,
  [string]$localPath = "",
  [string]$collectionUrl = ""
)
  $collectionParameter = getCollectionParameter $collectionUrl
  $workspaceParameter = getWorkspaceParameter $workspaceName
  executeTfsCommand `
    'workfold' `
    'map' `
    ($collectionParameter, $workspaceParameter, $serverPath, $localPath)    
}

function New-TfsWorkspace {
param(
  [string]$name,
  [string]$collectionUrl = "",
  [string]$comment = "",
  [string]$path = "",
  [switch]$noMap = $false
)
  $collectionParameter = getCollectionParameter $collectionUrl   
  $commentParameter = getCommentParameter $comment
  $noPromptParameter = getNoPromptParameter
  $locationParameter = getLocationParameter
  $permissionParameter = getPermissionParameter
  $computerParameter = getComputerParameter
  if ($noMap)
  {
    # use a temporary folder for $path that will be removed immediately 
    # afterwards since removing mapping the passed in value for $path, if any,
    # is irrelevant
    $path = createTemporaryFolder
  }
  executeTfsCommand `
    'workspace' `
    'new' `
    (
      $noPromptParameter, 
      $collectionParameter, 
      $commentParameter, 
      $locationParameter, 
      $permissionParameter, 
      $computerParameter, 
      $name
    ) `
    $path
  if ($noMap)
  {
    # Previous command forced setting a mapping to root $/ which is not required
    Remove-TfsWorkFolderMapping $path $name
    deleteTemporaryFolder $path
  }
}

function Remove-TfsCloak {
param(
  [string]$serverPath,
  [string]$workspaceName = "",
  [string]$collectionUrl = ""
)
  $collectionParameter = getCollectionParameter $collectionUrl
  $workspaceParameter = getWorkspaceParameter $workspaceName
  executeTfsCommand `
    'workfold' `
    'decloak' `
    ($serverPath, $workspaceParameter, $collectionParameter)
}

function Remove-TfsWorkFolderMapping {
param(
  [string]$localOrServerPath,
  [string]$workspaceName = "",
  [string]$collectionUrl = ""
)
  $collectionParameter = getCollectionParameter $collectionUrl
  $workspaceParameter = getOptionalNamedParameter 'workspace' $workspaceName
  executeTfsCommand `
    'workfold' `
    'unmap' `
    ($collectionParameter, $workspaceParameter, $localOrServerPath)
}

function Remove-TfsWorkspace {
param(
  [string]$name,
  [string]$collectionUrl = "",
  [switch]$confirm = $false
)
  $collectionParameter = getCollectionParameter $collectionUrl
  $nopromptParameter = getNoPromptParameter (!$confirm)
  executeTfsCommand `
    'workspace' `
    'delete' `
    ($noPromptParameter, $collectionParameter, $name)
}

function Show-TfsContents {
param (
  [string]$localOrServerPath = "",
  [string]$version = "",
  [string]$collectionUrl = "",
  [switch]$recursive = $false,
  [switch]$foldersOnly = $false,
  [switch]$includeDeleted = $false
)
  $collectionParameter = getCollectionParameter $collectionUrl
  $versionParameter = getVersionParameter $version
  $recursiveParameter = getSwitchParameter 'recursive' $recursive
  $foldersOnlyParameter = getSwitchParameter 'folders' $foldersOnly
  $includeDeletedParameter = getSwitchParameter 'deleted' $includeDeleted
  executeTfsCommand `
    'dir' `
    '' `
    (
      $localOrServerPath, 
      $versionParameter,
      $recursiveParameter,
      $foldersOnlyParameter,
      $includeDeletedParameter
    ) 
}

function Show-TfsHistory {
param (
  [string]$localOrServerPath = "",
  [int]$maxEntries = -1,
  [string]$collectionUrl = "",
  [switch]$recursive = $false,
  [switch]$window = $false,
  [switch]$ascending = $false
)
  $collectionParameter = getCollectionParameter $collectionUrl
  $nopromptParameter = getNoPromptParameter (-not $window)
  $recursiveParameter = getSwitchParameter 'recursive' $recursive
  $stopAfterParameter = getStopAfterParamater $maxEntries
  $sortDirection = ""
  if ((-not $window) -and $ascending)
  {
    $sortDirection = "ascending"
  }
  $sortParameter = getSortParameter $sortDirection
  
  if ($localOrServerPath -eq "")
  {
    $localOrServerPathParameter = "."
  }
  else
  {
    $localOrServerPathParameter = $localOrServerPath
  }
  executeTfsCommand `
    'history' 
    (
      $recursiveParamater,
      $nopromptParameter,
      $stopAfterParameter,
      $localOrServerPathParameter,
      $sortParameter
    )
}

function Show-TfsWorkspaces {
  executeTfsCommand 'workspaces'
}

function getCollectionParameter {
param (
  [string]$collectionUrl
)
  return getOptionalNamedParameter 'collection' $collectionUrl
}

function getWorkspaceParameter {
param (
  [string]$workspaceName
)
  return getOptionalNamedParameter 'workspace' $workspaceName
}

function getCommentParameter {
param (
  [string]$comment
)
  return getOptionalNamedParameter 'comment' ('''' + $comment + '''')
}

function getVersionParameter {
param (
  [string]$version
)
  return getOptionalNamedParameter 'version' $version
}

function getNoPromptParameter {
param (
  [bool]$enabled = $true
)
  return getSwitchParameter 'noprompt' $enabled
}

function getLocationParameter {
  return getOptionalNamedParameter 'location' 'server'
}

function getPermissionParameter {
  return getOptionalNamedParameter 'permission' 'private'
}

function getComputerParameter {
  return getOptionalNamedParameter 'computer' $env:COMPUTERNAME
}

function getSortParameter {
param (
  [string]$sortDirection = ""
)
  return getOptionalNamedParameter 'sort' $sortDirection
}

function getOptionalNamedParameter {
param (
  [string]$name,
  [string]$value = ""
)
  $parameter = ""
  if ($value -ne "")
  {
    $parameter = getParameter $name $value
  }
  return $parameter
}

function getSwitchParameter {
param (
  [string]$name,
  [bool]$enabled = $true
)
  $parameter = ""
  if ($enabled)
  {
    $parameter = getParameter $name
  }
  return $parameter
}

function getParameter {
param (
  [string]$name = "",
  [string]$value = ""
)
  $parameter = ""
  if ($name -ne "")
  {
    $parameter = "/" + $name
    if ($value -ne "")
    {
      $parameter += ":" + $value
    }
  }
  else
  {
    $parameter = $value
  }
  return $parameter
}

function executeTfsCommand {
param (
  [string]$command,
  [string]$subCommand = "",
  [string[]]$arguments = @(),
  [string]$location = ""
)
  $useCurrentDirectory = $location -eq ""
  if (!$useCurrentDirectory)
  {
    # command needs to be in a specific directory to work correctly so first 
    # switch location
    $previousLocation = Switch-Location $path
  }
  $subCommandParameter = getParameter $subCommand
  $allArguments = ($command, $subCommandParameter) + $arguments
  tf $allArguments
  if (!$useCurrentDirectory)
  {
    # set location back to original to avoid any unexpected behaviour
    Set-Location $previousLocation
  }
}

function createTemporaryFolder {
  $randomValue1 = Get-Random
  $randomValue2 = Get-Random
  do
  {
    $path = 'C:\temp-' + $randomValue1 + '-' + $randomValue2
  }
  while (Test-Path $path)
  New-Item -ItemType Container $path | Out-Null
  return $path
}

function deleteTemporaryFolder {
param (
  [string]$path
)
  if ($path.StartsWith('C:\temp-'))
  {
    Remove-Item -Path $path -Recurse -Force
  }
}

Set-Alias Add-TfsCloak New-TfsCloak
Export-ModuleMember New-TfsCloak -Alias Add-TfsCloak

Set-Alias Add-TfsWorkFolderMapping New-TfsWorkFolderMapping
Export-ModuleMember New-TfsWorkFolderMapping -Alias Add-TfsWorkFolderMapping

Set-Alias Add-TfsWorkspace New-TfsWorkspace
Export-ModuleMember New-TfsWorkspace -Alias Add-TfsWorkspace

Set-Alias Delete-TfsCloak Remove-TfsCloak
Export-ModuleMember Remove-TfsCloak -Alias Delete-TfsCloak

Set-Alias Delete-TfsWorkFolderMapping Remove-TfsWorkFolderMapping
Export-ModuleMember Remove-TfsWorkFolderMapping `
  -Alias Delete-TfsWorkFolderMapping

Set-Alias Delete-TfsWorkspace Remove-TfsWorkspace
Export-ModuleMember Remove-TfsWorkspace -Alias Delete-TfsWorkspace

Set-Alias List-TfsContents Show-TfsContents
Export-ModuleMember Show-TfsContents -Alias List-TfsContents

Set-Alias List-TfsWorkspaces Show-TfsWorkspaces
Export-ModuleMember Show-TfsWorkspaces -Alias List-TfsWorkspaces
