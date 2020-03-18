
if [ ! -n "$1" ] ;then
    echo "you have not input a word!"
else
    git add *
    git commit -m $1

fi
