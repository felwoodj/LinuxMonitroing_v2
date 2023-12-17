#!/bin/bash

function AddLogLineFile {
    # путь
    fullPath=$1
    date=$(date +"%d %b %Y %H:%M:%S") 
    # размер файла
    size=$3"kb"

    line="$fullPath "---" $date "---" $size"

    sudo echo $line >> log.txt
}

function AddLogLineFolder {
    # путь
    fullPath=$1
    date=$(date +"%d %b %Y %H:%M:%S")

    line="$fullPath "---" $date"

    sudo echo $line >> log.txt
}

function IsOverMemory {
    if [[ $(GetfreeSize) -lt "1024" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

function GetfreeSize {
    echo `df / -BM | awk '{print $4}' | tail -n 1 | cut -d 'M' -f1` 
}

function GetDate {
    echo `date +%d%m%y`
}

function MakeDir {
    path=$absolutePath/$(FolderNameGen $2)_$('GetDate')
    sudo mkdir -p $path

    AddLogLineFolder $path $(GetDate)
    echo $path
}

function FolderNameGen {
    # имя папки
    str=$folderName
    max_len=$1
    charsNumber=${#str}

    strlen=${#str}
    lastChar=${str:strlen-1}
    firstChar=${str:0:1}

    for (( i=$strlen; i<$max_len; i++)); do
        # добавляем символ в строку
        str="${str:0:1}${str}" 
        let "strlen+=1"
    done

    echo $str
}

function FileNameGen {
    strFile=$fileName

    extCharset=${strFile#*.} # расширение
    baseCharset=${strFile%%.*} # имя файла
    baselen=${#baseCharset}
    base=$baseCharset
    baseMaxLen=$1

    for (( i=$baselen; i<$baseMaxLen; i++)); do
        base="${base:0:1}${base}" # добавляем символ в строку
        let "strlen+=1"
    done

    strlenExt=${#extCharset}
    maxLenExt=3
    ext=$extCharset
    if [[ $maxLenExt -lt 3 ]]; then
        maxLenExt=3
    fi

    for (( i=$strlenExt; i<$maxLenExt; i++)); do
        ext="${ext:0:1}${ext}" # добавляем символ в стрроку
        let "strlen+=1"
    done

    echo "$base.$ext"_"$(GetDate)"
}

function MakeFile {
    FolderPath=$1
    baseCharset=${fileName%%.*} # создание файла
    baselen=${#baseCharset}
    nameLen=$(($baselen))
    if [[ $nameLen -lt 4 ]]; then
        let "nameLen+=(4-nameLen)"
    fi
    let "nameLen+=j"

    # путь к файлу
    fileName=$(FileNameGen $nameLen)

    # дата создания
    AddLogLineFile $FolderPath/$fileName $(GetDate) $allowedSize

    # размер файла
    sudo fallocate -l ${fileSize^} $FolderPath/$fileName
}

function create {
    nameLen=${#folderName}
    offset=$nameLen

    if [[ nameLen -lt 4 ]]; then
        offset=(4 - $nameLen)
    fi

    for (( i=$offset; i <($foldersNumber+$offset); i++ )); do
        dirPath=$(MakeDir $absolutePath $i) # длина имени каждой папки
        absolutePath=$dirPath

        for (( j =0; j<$fileNumber; j++ )); do
            if [[ $(IsOverMemory) == "true" ]]; then
                echo "Ошибка - закончилось место, требуется минимум 1ГБ свободного места"
                exit
            else
                MakeFile $dirPath $j
            fi
        done
    done
}

