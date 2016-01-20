# GitHubPagesForGAP

This repository can be used to quickly set up a website hosted by
[GitHub](https://github.com/) for GAP packages using a GitHub repository.
Specifically, this uses [GitHub pages](https://pages.github.com/)
by adding a `gh-pages` branch to your package repository which
contains data generated from the `PackageInfo.g` file of your package.

## Initial setup

The following instructions assume you do not already have a `gh-pages`
branch in your repository. If you do have one, you should delete it before
following these instructions.

1. Go into your clone of your package repository.

2. In there, create a fresh clone of your package in a subdirectory `gh-pages`:

   ```
   git clone https://github.com/USERNAME/REPOSITORY gh-pages
   ```

3. Change into the fresh clone and add a new remote pointing to the
   [GitHubPagesForGAP repository](https://github.com/fingolfin/GitHubPagesForGAP):

   ```
   cd gh-pages
   git remote add gh-gap https://github.com/fingolfin/GitHubPagesForGAP
   git fetch gh-gap
   ```

4. Create a fresh gh-pages branch from the new remote:

   ```
   git checkout -b gh-pages gh-gap/gh-pages --no-track
   ```

5. Add in copies of your PackageInfo.g, README and manual:

   ```
   cp -f ../PackageInfo.g ../README .
   cp -f ../doc/*.{css,html,js,txt} doc/
   ```

6. Now run the `update.g` GAP script. This extracts data from your
   `PackageInfo.g` file and puts that data into `_data/package.yml`.
   From this, the website template can populate the web pages with
   some sensible default values.

   ```
   gap update.g
   ```

7. Commit and push everything.

   ```
   git add PackageInfo.g README doc/ _data/package.yml
   git commit -m "Setup gh-pages based on GitHubPagesForGAP"
   git push --set-upstream origin gh-pages
   ```

That's it. You can now see your new package website under
http://USERNAME.github.io/REPOSITORY/ (of course after
adjusting USERNAME and REPOSITORY suitably).


## Adjusting the content and layout

GitHubPagesForGAP tries to automatically provide good defaults for
most packages. However, you can tweak everything about it:

* To adjust the page layout, edit the files `stylesheets/styles.css`
and `_layouts/default.html`.

* To adjust the content of the front page, edit `index.md` (resp.
  for the content of the sidebar, edit `_layouts/default.html`

* You can also add additional pages, in various formats (HTML,
Markdown, Textile, ...).

For details, please consult the [Jekyll](http://jekyllrb.com/)
manual.


## Testing the site locally

If you would like to test your site on your own machine, without
uploading it to GitHub (where it is visible to the public), you can do
so by installing [Jekyll](http://jekyllrb.com/), the static web site
generator used by GitHub to power GitHub Pages.

Once you have installed Jekyll as described on its homepage, you can
test the website locally as follows:

1. Go to the `gh-pages` directory we created above.

2. Run jekyll (this launches a tiny web server on your machine):

   ```
   jekyll serve -w
   ```

3. Visit the URL http://localhost:4000 in a web browser.


## Updating after you made a release

Whenever you make a release of your package (and perhaps more often than
that), you will want to update your website. The easiest way is to use
the `release` script from the [ReleaseTools][]. However, you can also do
it manually. The steps for doing it are quite similar to the above:

1. Go to the `gh-pages` directory we created above.

2. Add in copies of your PackageInfo.g, README and manual:

   ```
   cp -f ../PackageInfo.g ../README .
   cp -f ../doc/*.{css,html,js,txt} doc/
   ```

3. Now run the `update.g` GAP script.

4. Commit and push the work we have just done.

   ```
   git add PackageInfo.g README doc/ _data/package.yml
   git commit -m "Update web pages"
   git push
   ```

A few seconds after you have done this, your changes will be online
under http://USERNAME.github.io/REPOSITORY/ .


## Updating to a newer version of GitHubPagesForGAP

Normally you should not have to ever do this. However, if you really want to,
you can attempt to update to the most recent version of GitHubPagesForGAP via
the following instructions. The difficulty of such an update depends on how
much you tweaked the site after initially cloning GitHubPagesForGAP.

1. Go to the `gh-pages` directory we created above.
   Make sure that there are no uncommitted changes, as they will be lost
   when following these instructions.

2. Fetch changes made to GitHubPagesForGAP.
   ```
   git fetch gh-gap
   ```

3. Attempt to merge these changes. This may produce multiple merge conflicts,
   so ideally, you should be familiar with dealing with such merge conflicts.
   ```
   git pull gh-gap gh-pages
   ```
   If at any point you don't know how to continue, you can abort the merge
   process and revert to the original state by issuing this command:
   ```
   git merge --abort
   ```

4. This may produce merge conflicts. Most likely you will have conflicts in
   the file `_data/package.yml`, but these are easy to resolve as follows:
   ```
   gap update.g
   git add _data/package.yml
   ```
   If you are lucky, this is the only conflict (check with `git status`).



## Packages using GitHubPagesForGAP
Packages using GitHubPagesForGAP include the following:

* https://gap-packages.github.io/anupq
* https://gap-packages.github.io/cvec
* https://gap-packages.github.io/genss
* https://gap-packages.github.io/io
* https://gap-packages.github.io/NormalizInterface
* https://gap-packages.github.io/nq
* https://gap-packages.github.io/orb
* https://gap-packages.github.io/polenta
* https://gap-packages.github.io/recog
* https://gap-packages.github.io/recogbase
* https://gap-packages.github.io/SingularInterface


## Contact

Please submit bug reports, suggestions for improvements and patches via
the [issue tracker](https://github.com/fingolfin/GitHubPagesForGAP/issues).

You can also contact me directly via [email](max@quendi.de).

Copyright (c) 2013-2016 Max Horn

[ReleaseTools]: https://github.com/fingolfin/ReleaseTools
