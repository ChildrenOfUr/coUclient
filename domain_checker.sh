branch="$(git rev-parse --abbrev-ref HEAD)"
if [ "$branch" == "master" ]
then
    echo "server.childrenofur.com" > web/server_domain.txt
    echo "branch=$branch"
    echo "server domain will be server.childrenofur.com"
else
    echo "robertmcdermot.com" > web/server_domain.txt
    echo "branch=$branch"
    echo "server domain will be robertmcdermot.com"
fi
