This repository can be used to quickly set up GitHub pages for
GAP packages.


## Initial setup

To use it (under the assumption that you have no gh-pages branch
in the git repository of your GitHub hosted GAP package), do this:

1) Create a fresh clone of your package repository:
  
  git clone https://github.com/user/repository.git
  cd repository

2) Add a new remote pointing to this repository:
  
  git remote add gh-gap https://github.com/fingolfin/GitHubPagesForGAP.git
  git fetch gh-gap

3) Make a copy of some files

   mkdir tmp
   cp PackageInfo.g README tmp/

4) Create a fresh gh-pages branch from the new remote

  git checkout -b gh-pages gh-gap/gh-pages --no-track

5) Add in your own PackageInfo.g and README:

  cp tmp/PackageInfo.g tmp/README .
  rm -rf tmp

6) Regenerate stuff:

  gap update.g

7) Commit and push

  git add PackageInfo.g README _data/package.yml
  git commit -m "Setup gh-pages based on GitHubPagesForGAP"
  git push --set-upstream origin gh-pages
  


## Updating after you made a release

TODO

## Updating to a newer version of GitHubPagesForGAP

TODO: explain about "git pull --merge gh-gap gh-pages"

