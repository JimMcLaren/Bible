BaseDir=$(dirname "$(readlink -f "${BASH_SOURCE}")")
testrun=false

startme(){
    if [[ "$testrun" = "true" ]]; then
    echo 
    echo 
        echo "************"
        echo "* Test Run *"
        echo "************"
    echo 
    echo 
    fi

    echo 
    answer="Select the EPUB to build "
    select option in "WEB-chronological" "WEB-NT-chronological" "WEB-OT-chronological" quit
    do 
        case $option in 
            "WEB-chronological")
                buildWEB $option
                startme
                break
            ;;
            "WEB-NT-chronological")
                buildWEB $option
                startme
                break
            ;;
            "WEB-OT-chronological" )
                buildWEB $option
                startme
                break
            ;;
            "quit")
                break
            ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

buildWEB()
{
    echo $1
    # read -p "Waiting..." -t 15
    CurrentDate=$(date +"%F-%H-%M-%S")
    BuildDir="$BaseDir/../process/buildDir/$1-$CurrentDate"
    BuildLog=$BaseDir/../process/logs/$1-$CurrentDate.log
    echo Logging in $BuildLog | tee "$BuildLog"
    # read -p "logging" -t 15
    RemoveBuildDirWhenDone=false
    mkdir "$BuildDir" | tee -a "$BuildLog"
    sourceRoot="$BaseDir/../Source Text/Chapters"
    NTSource="$sourceRoot/DeuteroCanonical/NT"
    NTSplitChapterSource="$sourceRoot/SplitChapters/NT"
    OTSource="$sourceRoot/DeuteroCanonical/OT"
    OTSplitChapterSource="$sourceRoot/SplitChapters/OT"
    Outdir="$BaseDir/../process/output"
    mkdir "$Outdir" | tee -a "$BuildLog"
    # read -p "Pausing for 5 seconds" -t 5

    # for thefile in "$sourceRoot/Extras/*.xhtml"; do cp "$thefile" "$BuildDir/OEBPS/";done
    cd "$sourceRoot"
    mkdir "$BuildDir/OEBPS/" | tee -a "$BuildLog"
    
    # echo $(pwd) >> "$BuildLog"
    # ls ./Extras/* >> "$BuildLog"
    for thefile in ./Extras/*;do echo "Copying $thefile" >> "$BuildLog";done | tee -a "$BuildLog"
    for thefile in ./Extras/*; do cp "$thefile" "$BuildDir/OEBPS/";done | tee -a "$BuildLog"
    # read -p "Pausing for 5 seconds" -t 5
    ProjectCommon="$BaseDir/../epubs/common"
    case $1 in 
        "WEB-chronological")
            ProjectSource="$BaseDir/../epubs/Chronological"
            OutputFile="$Outdir/WEB-Chronological-$CurrentDate.epub"
            copyProject
            copyNT
            copyOT
        ;;
        "WEB-NT-chronological")
            ProjectSource="$BaseDir/../epubs/NT Chronological"
            OutputFile="$Outdir/WEB-Chronological-NT-$CurrentDate.epub"
            copyProject
            copyNT
        ;;
        "WEB-OT-chronological" )
            ProjectSource="$BaseDir/../epubs/OT Chronological"
            OutputFile="$Outdir/WEB-Chronological-OT-$CurrentDate.epub"
            copyProject
            copyOT
        ;;
    esac
    buildEPUB
    if [[ "$RemoveBuildDirWhenDone" = "true" ]]; then
        rm -rv "$BuildDir" | tee -a "$BuildLog"
    fi

}

buildEPUB()
{
    # testrun=true
    if [ "$testrun" = "false" ]; then
        echo Creating $OutputFile | tee -a "$BuildLog" 
        echo "(cd $BuildDir && zip -r - mimetype META-INF OEBPS) .gt. $OutputFile " >> $BuildLog
        (cd "$BuildDir" && zip -r - mimetype META-INF OEBPS) > "$OutputFile" | tee -a "$BuildLog"
        echo EPUB created at $OutputFile
    else
        echo "Creating EPUB"
        echo "*************"
        echo "Source: $BuildDir "
        echo "Destination: $OutputFile"
    fi
}

copyNT(){
    if [ "$testrun" = "false" ]; then
        rsync -avi "$NTSource/" "$BuildDir/OEBPS/" | tee -a "$BuildLog"
        rsync -avi "$NTSplitChapterSource/" "$BuildDir/OEBPS/" | tee -a "$BuildLog"
        # read -p "Pausing for 5 seconds" -t 5
    else
        echo "TEST NT Build"
        echo rsync -avi "$NTSource/" "$BuildDir/OEBPS/"
        echo rsync -avi "$NTSplitChapterSource/" "$BuildDir/OEBPS/"
    fi
}

copyOT(){
    if [ "$testrun" = "false" ]; then
        rsync -avi "$OTSource/" "$BuildDir/OEBPS/" | tee -a "$BuildLog"
        rsync -avi "$OTSplitChapterSource/" "$BuildDir/OEBPS/" | tee -a "$BuildLog"
        # read -p "Pausing for 5 seconds" -t 5
    else
        echo "TEST OT build"
        echo rsync -avi "$OTSource/" "$BuildDir/OEBPS/"
        echo rsync -avi "$OTSplitChapterSource/" "$BuildDir/OEBPS/"
        # read -p "Pausing for 5 seconds" -t 5
    fi
}

copyProject(){
    if [ "$testrun" = "false" ]; then
        echo "This is not a test!"
        rsync -avi "$ProjectSource/" "$BuildDir/" | tee -a "$BuildLog"
        rsync -avi "$ProjectCommon/" "$BuildDir/" | tee -a "$BuildLog"
    else
        echo "TEST Project move"
        echo rsync -avi "$ProjectSource/" "$BuildDir/"
    fi
}

startme
