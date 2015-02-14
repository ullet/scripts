# Wrapper functions around git commands to enable setting aliases.

# Copyright (c) 2015 Trevor Barnett
# Released under the terms of The MIT License (MIT)

# Note:
# Uses approved verb 'Invoke' for all exported functions to avoid warnings.
# Almost certainly bad use of verb, but only really interested in the aliases.

function defineAllAliases() {
  defGitAliases add git-ad, gad, ga, gadd
  defGitAliases "add -A" git-add-all, gaa Invoke-GitAddA
  defGitAliases branch git-br, gbr
  defGitAliases checkout git-co, gco
  defGitAliases clone git-cl, gcl, gclone
  defGitAliases commit git-ct, gct, gcom
  defFn Invoke-GitCommitWithMessage { param ($m) git commit -m $m $ARGS } gcmt
  defGitAliases diff git-df, gdf, gdiff, gdif
  defGitAliases fetch git-ft, gft
  defGitAliases help git-hp, ghp, ghlp
  defGitAliases init git-in, gin, ginit
  defGitAliases log git-lg, glg, glog
  defGitAliases merge git-mg, gmg
  defGitAliases pull git-pl, gpl
  defGitAliases push git-pu, gpu
  defGitAliases status git-st, gst, gs
  defGitAliases rebase git-rb, grb
  defGitAliases rm grm
}

function defGitAliases($command, $aliases, $functionName) {
  $aliases = withStandardAliases $command $aliases
  $functionName = constructFunctionNameIfNotSet $command $functionName  
  $block = [scriptblock]::Create("git $command `$ARGS")
  defFn $functionName $block $aliases
}

function withStandardAliases($command, $aliases) {
  if ($command -match '^\p{L}[\p{L}\p{N}]+$') {
    @("git-$command", $aliases) | % {$_} | ? {$_}
  } else {
    $aliases | % {$_} | ? {$_}
  }
}

function constructFunctionNameIfNotSet($command, $functionName) {
  if ($functionName -eq $null) {
    "Invoke-Git" + (Get-Culture).TextInfo.ToTitleCase($command)
  } else {
    $functionName
  }
}

function defFn($functionName, $scriptblock, $aliases) {
  $fnDef = "function Script:$functionName {
    Invoke-Command {$scriptblock} -ArgumentList `$ARGS
  }"
  Invoke-Expression $fnDef
  export $functionName $aliases
}

function export($function, $aliases) {
  setAliases $aliases $function
  if ($aliases -eq $null) {
    $aliases = '*'
  }
  Export-ModuleMember -function $function -alias $aliases
}

function setAliases($aliases, $command) {
  if ($aliases -eq $null) { return }
  foreach ($alias in $aliases) {
    set-alias -Name:$alias -Value:$command -Scope:script
  }
}

defineAllAliases
