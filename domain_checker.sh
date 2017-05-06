branch=$CI_BRANCH
if [ "$branch" == "master" ]
then
    echo "server.childrenofur.com" > web/server_domain.txt
    echo "branch=$branch"
    echo "server domain will be server.childrenofur.com"
else
    echo "robiotic.net" > web/server_domain.txt
    echo "branch=$branch"
    echo "server domain will be robiotic.net"
fi
