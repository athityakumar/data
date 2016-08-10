function Data 

{ 

cd ~/data; 

ruby main.rb $1 $2 $3;

cd ~/;

. ~/data/Data; 

}

if test -f "/data/Data"; 

then

    . ~/data/Data;

else

    cd ~/data;

    ruby main.rb Init;

    cd ~/;

    . ~/data/Data

fi