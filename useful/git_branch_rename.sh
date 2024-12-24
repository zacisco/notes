#!/usr/bin/env bash

read -ep "Enter repository local path: " repo
read -p "Enter default branch: " def_branch
read -p "Enter old branch name: " branch
read -p "Enter new branch name: " new_branch

cd $repo

git fetch
git checkout -b $branch origin/$branch
git branch -m $branch $new_branch
git fetch origin --prune
git push origin $new_branch:$new_branch
git checkout $def_branch
git branch -d $new_branch

exit $?
