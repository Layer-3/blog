
if [ ! -n "$1" ] ;then
    echo "you have not input a word!"
else
    hugo
    git add *
    git commit -m "$*"
    git push origin master
fi
