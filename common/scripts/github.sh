#!/bin/sh

# Parameters
# 1 = Branch
# 2 = Message

echo "Committing all local changes to repositories."

cd ..
# common
cd ..
# /

echo "Pulling from branch $1."

git pull origin "$1"

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

echo "Copying common files to Heroku web apps."

for d in */ ; do
	if [ "$d" != "common/" ] ; then
		echo "Copying common files to $d."
		if [ ! -d "$d/web/utils" ] ; then
			echo "Making directory $d/web/utils."
			mkdir "$d"/web/utils
		fi
		cp common/utils/* "$d"/web/utils
		echo "Copying common files to $d complete."
	fi
done

echo "Committing individual Heroku web apps."

for d in */ ; do
	if [ "$d" != "common/" ] ; then
		echo "Commiting $d to Heroku."
		cd "$d"/web
		git status
		git add -A
		git commit -m "$2"
		git push heroku master
		cd ..
	fi
done

echo "Process complete."