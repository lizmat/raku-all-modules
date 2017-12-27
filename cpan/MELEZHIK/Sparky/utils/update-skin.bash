set -x
set -e
skin=$1
curl -s -f https://bootswatch.com/3/$skin/bootstrap.min.css -o public/css/bootstrap.min.css
curl -s -f https://bootswatch.com/3/$skin/bootstrap.css -o public/css/bootstrap.css
