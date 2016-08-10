function Data 

{ 

cd ~/data; 

ruby main.rb $1 $2 $3;

cd ~/;

. ~/data/Data; 

}

if test -f "/home/`whoami`/data/Data"; then

    . ~/data/Data;

else

    if test -f "/home/`whoami`/data/main.rb"; then

        cd ~/data;

        ruby main.rb Init;

        cd ~/;

        . ~/data/Data

    fi    

fi
