BuildDate=$(date +"%F-%H-%M-%S")
BuildDir=./buildDir

# Start="../WEB\ Master/Chapters"
# Destination=$Start/NT
CurrentDate=$(date +"%F-%H-%M-%S")
BuildLog=./logs/Build-$CurrentDate.log
# BaseDir="../WEB Master/Chapters"
BaseDir=$(dirname "$(readlink -f "${BASH_SOURCE}")")
BuildDir="$BaseDir/buildDir"
# SourceDir="$BaseDir/DeuteroCanonical"
# ProjectSource="../../World English Bible/Projects/World English Bible/Chronological/"
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
    CurrentDate=$(date +"%F-%H-%M-%S")
    BuildLog=./logs/Build-$CurrentDate.log
    echo Logging in $BuildLog | tee $BuildLog
    RemoveBuildDirWhenDone=false
    OldBuildDir=$BuildDir
    BuildDir="$BuildDir/WEB-$CurrentDate"
    mkdir "$BuildDir" | tee -a $BuildLog

    sourceRoot="$BaseDir/../Master Source/World English Bible/Chapters"
    NTSource="$sourceRoot/DeuteroCanonical/NT"
    NTSplitChapterSource="$sourceRoot/SplitChapters/NT"
    OTSource="$sourceRoot/DeuteroCanonical/OT"
    OTSplitChapterSource="$sourceRoot/SplitChapters/OT"
    case $1 in 
        "WEB-chronological")
            mkdir "$ProjectSource/../Output"
            ProjectSource="$BaseDir/../Projects/World English Bible/Chronological"
            OutputFile="$ProjectSource/../Output/WEB-Chronological-$CurrentDate.epub"
            # OutputFile="$BaseDir/WEB-Chronological-$CurrentDate.epub"
            copyProject
            copyNT
            copyOT
        ;;
        "WEB-NT-chronological")
            mkdir "$ProjectSource/../Output"
            ProjectSource="$BaseDir/../Projects/World English Bible/NT Chronological"
            OutputFile="$ProjectSource/../Output/WEB-Chronological-NT-$CurrentDate.epub"
            copyProject
            copyNT
        ;;
        "WEB-OT-chronological" )
            mkdir "$ProjectSource/../Output"
            ProjectSource="$BaseDir/../Projects/World English Bible/OT Chronological"
            OutputFile="$ProjectSource/../Output/WEB-Chronological-OT-$CurrentDate.epub"
            copyProject
            copyOT
        ;;
    esac
    buildEPUB
    if [[ "$RemoveBuildDirWhenDone" = "true" ]]; then
        rm -rv "$BuildDir" | tee -a $BuildLog
    fi
    BuildDir=$OldBuildDir

}

buildEPUB()
{
    # testrun=true
    if [ "$testrun" = "false" ]; then
        echo Creating $OutputFile | tee -a $BuildLog 
        echo "(cd $BuildDir && zip -r - mimetype META-INF OEBPS) .gt. $OutputFile " >> $BuildLog
        (cd "$BuildDir" && zip -r - mimetype META-INF OEBPS) > "$OutputFile" | tee -a $BuildLog
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
        rsync -avi "$NTSource/" "$BuildDir/OEBPS/" | tee -a $BuildLog
        rsync -avi "$NTSplitChapterSource/" "$BuildDir/OEBPS/" | tee -a $BuildLog
    else
        echo "TEST NT Build"
        echo rsync -avi "$NTSource/" "$BuildDir/OEBPS/"
        echo rsync -avi "$NTSplitChapterSource/" "$BuildDir/OEBPS/"
    fi
}

copyOT(){
    if [ "$testrun" = "false" ]; then
        rsync -avi "$OTSource/" "$BuildDir/OEBPS/" | tee -a $BuildLog
        rsync -avi "$OTSplitChapterSource/" "$BuildDir/OEBPS/" | tee -a $BuildLog
    else
        echo "TEST OT build"
        echo rsync -avi "$OTSource/" "$BuildDir/OEBPS/"
        echo rsync -avi "$OTSplitChapterSource/" "$BuildDir/OEBPS/"
    fi
}

copyProject(){
    if [ "$testrun" = "false" ]; then
        echo "This is not a test!"
        rsync -avi "$ProjectSource/" "$BuildDir/" | tee -a $BuildLog
    else
        echo "TEST Project move"
        echo rsync -avi "$ProjectSource/" "$BuildDir/"
    fi
}


startme

# rsync -avi ./Master/ ./$BuildDir/ | tee ./$BuildDir.log
# # rsync -avi ./MetaInfo/ ./$BuildDir/ | tee ./$BuildDir.log
 

# # cd ./Builds/$BuildDir
# echo Creating Master-$BuildDate.epub >> $BuildDir.log 
# echo "(cd ./$BuildDir && zip -r - mimetype META-INF OEBPS) .gt. Master-$BuildDate.epub " >> $BuildDir.log
# (cd ./$BuildDir && zip -r - mimetype META-INF OEBPS) > Master-$BuildDate.epub 
# # (cd ./$BuildDir && zip -r - ./META-INF) > WEB-$BuildDate.epub 
# # (cd ./$BuildDir && zip -r - ./OEBPS) > WEB-$BuildDate.epub 
# # zip -r WEB-$BuildDate.epub ./$BuildDir | tee -a ./$BuildDir.log
# cd ../..
# echo Build log at $BuildDir.log

