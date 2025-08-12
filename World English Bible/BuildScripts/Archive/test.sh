
for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done
# if [ $RootFolder -eq '' ]; then
#     RootFolder=/mnt/data/OneDrive/Documents/eBook-mods/working/World\ English\ Bible/
# fi

# if [ $source -eq '' ]; then
#     source=Current
# fi

# if [ $source -eq Current ]; then
#     BuildDir=CurrentBuilds
#     SourceDir=Current
# fi

# if [ $source ]; then

# fi

if [[ $RootFolder == '' ]]; then
    RootFolder=/mnt/data/OneDrive/Documents/eBook-mods/working/World\ English\ Bible/
fi

if [[ $source == '' ]]; then
    source=Current
fi

if [[ $source == Current ]]; then
    BuildDir=CurrentBuilds
    SourceDir=Current
    BuildName=Current
fi

if [[ $source == NE* ]]; then
    echo here
    SourceDir=NET\ Master
    BuildDir=MasterBuilds
    BuildName=NET
fi

if [[ $source == WE* ]]; then
    echo there
    SourceDir=WEB\ Master
    BuildDir=MasterBuilds
    BuildName=WEB
fi

echo Root Folder=$RootFolder
echo source = $source
echo Source Dir = $SourceDir
echo Build Dir = $BuildDir
echo Build Name = $BuildName