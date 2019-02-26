# exit when any command fails
set -e
set -x

# PreChecks 
if [ $TRAVIS ] && [ $CI ]
then
echo "We are in a TravisCI env script continuing..."
else
echo "This script is meant to run ONLY TravisCI you should NOT run this!!!"
exit 1
fi

# Setup Variables 
VERSIONFILE='.travis/version.yml'
COMMIT_MESSAGE_SNIP=$(echo $TRAVIS_COMMIT_MESSAGE | cut -d' ' -f1-3)

major=$(grep 'major' $VERSIONFILE | awk '{ print $2}')
minor=$(grep 'minor' $VERSIONFILE | awk '{ print $2}')
emerg=$(grep 'emerg' $VERSIONFILE | awk '{ print $2}')

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

if [ "$TRAVIS_BRANCH" == "develop" ]
then

echo "TODO: DEVELOP BUILD AND DEPLOYMENT"

elif [ "$TRAVIS_PULL_REQUEST_BRANCH" == "develop" ] && [ "$TRAVIS_BRANCH" == "release" ];  then 
echo 'TODO: PR created develop -> release ... run tests'

elif [ "$TRAVIS_BRANCH" == "release" ] && [ "$TRAVIS_EVENT_TYPE" == "push" ]  && [ "$COMMIT_MESSAGE_SNIP" == "Merge pull request" ];then 
echo "TODO: PR to release approved ... do post PR tasks"
minor=$((minor+1))
release="release/$major.$minor.$emerg"

cat >$VERSIONFILE <<EOL
# DEVLELOPERS DO NOT TOUCH THIS FILE!!
major: ${major}
minor: ${minor}
emerg: ${emerg}
EOL

git remote rm origin
git remote add origin https://nickstanley574:${GH_TOKEN_TRAVISCI}@github.com/nickstanley574/pipeline-demo-protoype.git
git checkout release
git pull origin release
git add "$VERSIONFILE"
git commit -a -m "Travis build $TRAVIS_BUILD_NUMBER: Bumped version number to $release"
git push origin release
git checkout -b develop
git pull origin develop
git merge release
git push origin develop

elif [ "$TRAVIS_PULL_REQUEST_BRANCH" == "release" ] && [ "$TRAVIS_BRANCH" == "master" ];then 
echo 'TODO: PR created release -> master ... run tests'


elif [ "$TRAVIS_BRANCH" == "master" ] && [ "$TRAVIS_EVENT_TYPE" == "push" ];then
echo 'TODO: PR to master approved ... merge from release -> master '
release_num="$major.$minor.$emerg"
release="release/$release_num"

git remote rm origin
git remote add origin https://nickstanley574:${GH_TOKEN_TRAVISCI}@github.com/nickstanley574/pipeline-demo-protoype.git
git tag -a $release_num -m "Travis build $TRAVIS_BUILD_NUMBER: Tag version $release"
git push origin $release_num
git push origin master
git checkout -b develop
git pull origin develop
git merge master
git push origin develop

else 
echo "ELSE: TRAVIS_BRANCH=$TRAVIS_BRANCH TRAVIS_PULL_REQUEST_BRANCH=$TRAVIS_PULL_REQUEST_BRANCH"


fi