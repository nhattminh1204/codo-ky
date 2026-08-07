# OSRM Vietnam Docker Automated Setup Script for CodoKy
Param(
    [string]$DataDir = "E:\Workspace\CodoKy\codoky\osrm-data"
)

$ErrorActionPreference = "Stop"

Write-Host "Starting OSRM Vietnam Local Setup..." -ForegroundColor Cyan

# 1. Ensure Data Directory
if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Force -Path $DataDir | Out-Null
}

$PbfFile = "$DataDir\vietnam-latest.osm.pbf"
$OsrmFile = "$DataDir\vietnam-latest.osrm"

# 2. Check Docker
try {
    docker info | Out-Null
    Write-Host "Docker Desktop is running." -ForegroundColor Green
} catch {
    Write-Host "Docker Desktop is NOT running. Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

# 3. Pull OSRM Backend Image
Write-Host "Pulling OSRM backend image (osrm/osrm-backend)..." -ForegroundColor Yellow
docker pull osrm/osrm-backend

# 4. Check Map PBF Data
if (-not (Test-Path $PbfFile) -or (Get-Item $PbfFile).Length -lt 10000000) {
    Write-Host "File vietnam-latest.osm.pbf is missing or incomplete." -ForegroundColor Red
    exit 1
}
Write-Host "Map PBF data is ready." -ForegroundColor Green

# 5. OSRM Extraction & Contracting
Write-Host "Extracting road network profile (car.lua)..." -ForegroundColor Yellow
docker run --rm -v "${DataDir}:/data" osrm/osrm-backend osrm-extract -p /opt/car.lua /data/vietnam-latest.osm.pbf

Write-Host "Partitioning graph..." -ForegroundColor Yellow
docker run --rm -v "${DataDir}:/data" osrm/osrm-backend osrm-partition /data/vietnam-latest.osrm

Write-Host "Customizing graph..." -ForegroundColor Yellow
docker run --rm -v "${DataDir}:/data" osrm/osrm-backend osrm-customize /data/vietnam-latest.osrm

# 6. Stop previous container if running
docker rm -f osrm-vietnam 2>$null

# 7. Launch OSRM Container
Write-Host "Launching OSRM Container at port 5000..." -ForegroundColor Cyan
docker run -d --name osrm-vietnam -p 5000:5000 -v "${DataDir}:/data" osrm/osrm-backend osrm-routed --algorithm mld /data/vietnam-latest.osrm

Write-Host "OSRM Local Server is live at http://localhost:5000" -ForegroundColor Green
