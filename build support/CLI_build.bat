cd "%ProgramFiles(x86)%\National Instruments\LabVIEW 2019\"

g-CLI --lv-ver 2019 --arch 32 "buildWithCLI.vi" -- "2024.11.5.8"

cd "%ProgramFiles%\National Instruments\LabVIEW 2019\"

g-CLI --lv-ver 2019 --arch 64 "buildWithCLI.vi" -- "2024.11.5.8"