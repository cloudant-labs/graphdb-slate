rm -rf build
bundle exec middleman build --verbose
rm -rf couchapp/_attachments
mkdir couchapp/_attachments
cp -r build/* couchapp/_attachments
export TRAVIS_PULL_REQUEST=false
export TRAVIS_BRANCH="$1"
export USERNAME="${2}"
export PASSWORD="${3}"
rm -rf tmp
./scripts/deploy-branch.sh "$USERNAME" "$PASSWORD"
rm -rf tmp


