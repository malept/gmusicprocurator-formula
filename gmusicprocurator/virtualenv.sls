{% from "gmusicprocurator/map.jinja" import gmusicprocurator with context -%}
gmp-requirements-deps:
  pkg.installed:
    - names:
      - gcc
      - git
      - libffi-dev
      - libssl-dev
      - python-dev
      - python-pip
      - python-virtualenv
{%- if gmusicprocurator.frontend_enabled %}
{%- from 'node/map.jinja' import npm_requirement with context %}
  npm.bootstrap:
    - name: {{ gmusicprocurator.install_dir }}
    - user: {{ gmusicprocurator.user }}
    - require:
      - {{ npm_requirement }}
      - git: gmusicprocurator
  cmd.run:
    - name: node_modules/.bin/bower install
    - user: {{ gmusicprocurator.user }}
    - cwd: {{ gmusicprocurator.install_dir }}
    - require:
      - npm: gmp-requirements-deps
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
      - pkg: gmp-requirements-deps
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
      - cmd: gmp-requirements-deps
      - git: gmusicprocurator
      - file: gmp-venv-dir
{%- endif %}
  pip.installed:
    - editable: {{ gmusicprocurator.install_dir }}
    - bin_env: {{ gmusicprocurator.virtualenv_dir }}
    - user: {{ gmusicprocurator.user }}
{%- if gmusicprocurator.use_wheels %}{# requires pip >= 1.4 #}
    - use_wheel: True
{%- endif %}
    - require:
      - virtualenv: gmusicprocurator
