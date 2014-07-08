{% from "gmusicprocurator/map.jinja" import gmusicprocurator with context -%}
gmp-requirements-deps:
  pkg.installed:
    - names:
      - python-dev
      - git
      - python-virtualenv
{%- if gmusicprocurator.frontend_enabled %}
{%- from 'node/map.jinja' import npm_requirement with context %}
  npm.bootstrap:
    - name: {{ gmusicprocurator.install_dir }}
    - user: {{ gmusicprocurator.user }}
    - require:
      - {{ npm_requirement }}
      - git: gmusicprocurator
{%- endif %}

gmp-install-dir:
  file.directory:
    - name: {{ gmusicprocurator.install_dir }}
    - user: {{ gmusicprocurator.user }}
    - group: {{ gmusicprocurator.group }}
    - makedirs: True
    - recurse:
      - user
      - group

gmp-venv-dir:
  file.directory:
    - name: {{ gmusicprocurator.virtualenv_dir }}
    - user: {{ gmusicprocurator.user }}
    - group: {{ gmusicprocurator.group }}
    - makedirs: True
    - recurse:
      - user
      - group

gmusicprocurator:
  git.latest:
    - name: https://github.com/malept/gmusicprocurator.git
    - target: {{ gmusicprocurator.install_dir }}
    - user: {{ gmusicprocurator.user }}
    - require:
      - file: gmp-install-dir
  virtualenv.managed:
    - name: {{ gmusicprocurator.virtualenv_dir }}
    # The following directive fixes relative dirs for requirements*.txt for some reason
    - no_chown: True
{%- if gmusicprocurator.frontend_enabled %}
    - requirements: {{ gmusicprocurator.install_dir }}/requirements/formula-frontend.txt
{%- else %}
    - requirements: {{ gmusicprocurator.install_dir }}/requirements/base.txt
{%- endif %}
{%- if gmusicprocurator.use_wheels %}{# requires pip >= 1.4 #}
    - use_wheel: True
{%- endif %}
    - user: {{ gmusicprocurator.user }}
    - require:
      - pkg: gmp-requirements-deps
{%- if gmusicprocurator.frontend_enabled %}
      - npm: gmp-requirements-deps
      - git: gmusicprocurator
      - file: gmp-venv-dir
{%- endif %}
