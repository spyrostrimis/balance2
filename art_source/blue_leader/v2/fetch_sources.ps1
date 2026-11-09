$ErrorActionPreference = 'Stop'
$leaderRepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
$leaderTools = Join-Path $leaderRepoRoot 'artifacts/tooling'
New-Item -ItemType Directory -Force $leaderTools | Out-Null
$leaderMpfb = Join-Path $leaderTools 'mpfb2'
if (-not (Test-Path -LiteralPath $leaderMpfb)) {
    git clone --depth 1 --branch v2.0.18 https://github.com/makehumancommunity/mpfb2.git $leaderMpfb
    if ($LASTEXITCODE -ne 0) { throw 'MPFB checkout failed' }
}
$leaderRevision = git -C $leaderMpfb rev-parse HEAD
if ($leaderRevision -ne 'd0a32e57a7f915cb2f2b95410e2117648c7bbb7e') { throw 'Unexpected MPFB revision; use the pinned authoring version.' }
$leaderZip = Join-Path $leaderTools 'makehuman_system_assets_cc0_v2.zip'
if (-not (Test-Path -LiteralPath $leaderZip)) {
    Invoke-WebRequest 'https://files.makehumancommunity.org/asset_packs/makehuman_system_assets/makehuman_system_assets_cc0.zip' -OutFile $leaderZip
}
$leaderHash = (Get-FileHash -LiteralPath $leaderZip -Algorithm SHA256).Hash
if ($leaderHash -ne 'B542127A8E25547C7C29C19F2D1D2ADB9A664C80396ECD694095DBC8028A0107') { throw 'System pack hash differs from the reviewed source; verify the new version before use.' }
$leaderSystem = Join-Path $leaderTools 'makehuman-system'
if (-not (Test-Path -LiteralPath (Join-Path $leaderSystem 'eyes/high-poly/high-poly.mhclo'))) {
    Expand-Archive -LiteralPath $leaderZip -DestinationPath $leaderSystem
}
Write-Output 'Pinned MPFB and verified CC0 system assets are ready in artifacts/tooling.'
