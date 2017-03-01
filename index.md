---
layout: default
---

# GAP Package {{site.data.package.name}}

{{site.data.package.abstract}}

The current version of this package is version {{site.data.package.version}}.
For more information, please refer to [the package manual]({{site.data.package.doc-html}}).
There is also a [README](README.html) file and a [CHANGELOG](CHANGELOG.html).

## Dependencies

This package requires GAP version {{site.data.package.GAP}}
{% if site.data.package.needed-pkgs %}
The following other GAP packages are needed:
{% for pkg in site.data.package.needed-pkgs %}
- {% if pkg.url %}<a href="{{ pkg.url }}">{{ pkg.name }}</a>{% else %}{{ pkg.name }}{% endif %} {{ pkg.version }}{% endfor %}
{% endif %}
{% if site.data.package.suggested-pkgs %}
The following additional GAP packages are not required, but suggested:
{% for pkg in site.data.package.suggested-pkgs %}
- {% if pkg.url %}<a href="{{ pkg.url }}">{{ pkg.name }}</a>{% else %}{{ pkg.name }}{% endif %} {{ pkg.version }}{% endfor %}
{% endif %}

## Digraphs library

There is a library of various digraphs available for testing purposes
[here](digraphs-lib-0.5.tar.gz). More information is available
[here](lib-README.html).

## Author{% if site.data.package.authors.size != 1 %}s{% endif %}
{% for person in site.data.package.authors %}
{% if person.url %}<a href="{{ person.url }}">{{ person.name }}</a>{% else %}{{ person.name }}{% endif %}{% unless forloop.last %}, {% endunless %}{% else %}
{% endfor %}

{% if site.github.issues_url %}
## Feedback

For bug reports, feature requests and suggestions, please use the
[issue tracker]({{site.github.issues_url}}).
{% endif %}

## How to cite {{site.data.package.name}}
If you are using BibTeX, you can use the following BibTeX entry for the current 
version of {{site.data.package.name}}:

<pre style="white-space: pre-wrap;">@misc{james_d_mitchell_2016_198140,
  author       = {James D. Mitchell and
                  Wilf A. Wilson and
                  Michael Torpey and
                  Julius Jonu{\v s}as and
                  Markus Pfeiffer and
                  Jan De Beule and
                  Christopher Jefferson and
                  Luke Elliot and
                  Finlay Smith},
  title        = {gap-packages/Digraphs: 0.6.0},
  month        = dec,
  year         = 2016,
  doi          = {10.5281/zenodo.198140},
  url          = {https://doi.org/10.5281/zenodo.198140}
}</pre>
