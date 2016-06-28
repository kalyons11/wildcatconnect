#!/bin/sh

# Parameters
# 1 = Branch
# 2 = Message

echo "Committing all local changes to repositories."

cd ..
# common
cd ..
# /

echo "Committing to main repository."

git status
git add -A
if [ "$1" = "" ] ; then
	echo "Empty branch name. Exiting script."
	exit 0
elif [ "$2" = "" ] ; then
	echo "Empty commit message. Exiting script."
	exit 0
else
	git commit -m "$2"
	git push origin "$1"
fi

pwd

echo "Committing individual Heroku web apps."

for d in */ ; do
	echo "Commiting $d to Heroku."
	cd "$d"
	git status
	git add -A
	git commit -m "$2"
	git push heroku master
done

echo "Process complete."