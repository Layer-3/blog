
if [ ! -n "$*" ] ;then
    echo "you have not input a word!"
else
    hugo
    git add *
    git commit -m $1
    git push origin master
fi
