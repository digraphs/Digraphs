---
layout: default
---

# GAP Package {{site.data.package.name}}

{{site.data.package.abstract}}

The current version of this package is version {{site.data.package.version}}, released on {{site.data.package.date}}.
For more information, please refer to [the package manual]({{site.data.package.doc-html}}).
There is also a [README](README.html) file and a [CHANGELOG](CHANGELOG.html).

{% if site.data.package.license %}
  License: [{{ site.data.package.license }}](https://spdx.org/licenses/{{ site.data.package.license }})
{% endif %}

## Dependencies

This package requires GAP version {{site.data.package.GAP}}
{% if site.data.package.needed-pkgs %}
The following other GAP packages are needed:
{% for pkg in site.data.package.needed-pkgs %}
- {% if pkg.url %}<a href="{{ pkg.url }}">{{ pkg.name }}</a> {% else %}{{ pkg.name }} {% endif %}
  {{- pkg.version -}}
{% endfor %}
{% endif %}
{% if site.data.package.suggested-pkgs %}
The following additional GAP packages are not required, but suggested:
{% for pkg in site.data.package.suggested-pkgs %}
- {% if pkg.url %}<a href="{{ pkg.url }}">{{ pkg.name }}</a> {% else %}{{ pkg.name }} {% endif %}
  {{- pkg.version -}}
{% endfor %}
{% endif %}

## Digraphs library

There is a companion library of various digraphs that can be useful for testing
and experiments.
[Version 0.7 of this library is available to download here](digraphs-lib-0.7.tar.gz).
There is also a corresponding [README](lib-README.html) file for this library.

## Author{% if site.data.package.authors.size != 1 %}s{% endif %}
{% for person in site.data.package.authors %}
 {% if person.url %}<a href="{{ person.url }}">{{ person.name }}</a>{% else %}{{ person.name }}{% endif %}
 {%- if forloop.last -%}.{% else %}, {%- endif -%}
{% endfor %}

{% if site.data.package.contributors and site.data.package.contributors.size > 0 %}
## Contributor{% if site.data.package.contributors.size != 1 %}s{% endif %}
 {% for person in site.data.package.contributors %}
  {% if person.url %}<a href="{{ person.url }}">{{ person.name }}</a>{% else %}{{ person.name }}{% endif %}
  {%- if forloop.last -%}.{% else %}, {%- endif -%}
 {% endfor %}
{% endif %}

{% if site.github.issues_url %}
## Feedback

For bug reports, feature requests and suggestions, please use the
[issue tracker]({{site.github.issues_url}}).
{% endif %}

## How to cite {{site.data.package.name}}
If you are using BibTeX, you can use the following BibTeX entry for the current 
version of {{site.data.package.name}}:

<pre style="white-space: pre-wrap;">@misc{DeBeule{{site.data.package.date | date: "%Y"}}aa,
      Author = { Jan De Beule and
                 Julius Jonu{\v s}as and
                 James D. Mitchell and
                 Michael Torpey and
                 Maria Tsalakou and
                 Wilf A. Wilson },
      Title  = { Digraphs - {GAP} package, Version {{site.data.package.version}} },
      Month  = { {{site.data.package.date | date: "%b"}} },
      Year   = { {{site.data.package.date | date: "%Y"}} },
      Url    = { https://digraphs.github.io/Digraphs }
}</pre>
