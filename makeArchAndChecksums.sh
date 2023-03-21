#!/bin/bash

git_url=$1
repo_path=$2
readarray -td, projects <<< "$3,";
unset 'projects[-1]';

[ -z "$git_url" -o -z "$repo_path" -o -z "$projects" ] && echo -e "\nUsage: $(basename $0) <git_url> <group or user or repo> <projects>.\n\nExample: $(basename $0) https://user:pass@gitlab.ru demo project1,project2\n" && exit 0

dir=arch

[ ! -d $dir ] && mkdir $dir

cd $dir
work_dir=`pwd`

echo -e "\nClean all"
rm -rf *

echo -e "===============================================================================\n"

for proj in ${projects[@]}
do
    echo Download $proj
    git clone $git_url/$repo_path/$proj.git
    crcfile=$work_dir/${proj}_crc.txt
    md5file=$work_dir/${proj}_md5.txt
    sha1file=$work_dir/${proj}_sha1.txt

    cd $proj
    echo Clean some trash in $proj
    rm -rf .git
    cd ..
    echo Calculating checksumms of $proj
    find $proj -type f -exec bash -c "cksum \"{}\" >> $crcfile && md5sum \"{}\" >> $md5file && sha1sum \"{}\" >> $sha1file" \;
    echo Archivating $proj
    tar -czf ${proj}_`date +"%d-%m-%Y_%H-%M"`.tar.gz $proj
    rm -fr $proj
    echo -e "===============================================================================\n"
done

exit $?
