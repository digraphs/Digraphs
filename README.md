# GitHubgPagesForGAP

This repository can be used to quickly set up a website hosted by
[GitHub](https://github.com/) for GAP packages using a GitHub repository.
Specifically, this uses [GitHub pages](https://pages.github.com/)
by adding a `gh-pages` branch to your package repository which
contains data generated from your packages zPackageInfo.g` file.


## Initial setup

To use it (under the assumption that you have no gh-pages branch
in the git repository of your GitHub hosted GAP package), do this:

1. Go into a clone of your package repository, and make sure there
   are no local changes (this ensures you don't accidentally loose
   any changes when following this guide).



2. Add a new remote pointing to this repository:

  ```
  git remote add gh-gap https://github.com/fingolfin/GitHubPagesForGAP.git
  git fetch gh-gap
  ```

3. Make a copy of some files (we will use these in a moment)

  ```
   mkdir tmp
   cp PackageInfo.g README tmp/
  ```

4. Create a fresh gh-pages branch from the new remote:

  ```
  git checkout -b gh-pages gh-gap/gh-pages --no-track
  ```

5. Add in the copies we just made of your PackageInfo.g and README:

  ```
  cp tmp/PackageInfo.g tmp/README .
  rm -rf tmp
  ```

6. Now run the `update.g` GAP script, which extracts data from your
   `PackageInfo.g` file, then puts that data into `_data/package.yml`.
   From this, the website template can read the data to populate the
   web pages.

  ```
  gap update.g
  ```

7. Commit and push the work we 

  ```
  git add PackageInfo.g README _data/package.yml
  git commit -m "Setup gh-pages based on GitHubPagesForGAP"
  git push --set-upstream origin gh-pages
  ```


## Updating after you made a release

Whenever you make a release of your package (and perhaps more often than
that), you will want to update your website. The instructions for doing that
are quite similar to the above:

TODO. 




## Updating to a newer version of GitHubPagesForGAP

TODO: explain about "git pull --merge gh-gap gh-pages"


## Testing the site locally

If you want to test your site after making changes and before pushing it,
you can do this by installing [Jekyll](http://jekyllrb.com/), the static
site generator used by GitHub to run GitHub pages.

Once you have installed Jekyll as described on its homepage, you can
test the website locally as follows:

1. Go into the clone of your package repository you used above, and
   again make sure there are no local changes.

2. Switch to the `gh-pages` branch.

   ```
   git checkout gh-pages
   ```

3. Run jekyll.

   ```
   jekyll serve -w
   ```

4. Visit the URL http://localhost:4000 in a web browser.
