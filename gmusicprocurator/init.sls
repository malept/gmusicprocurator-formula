{% from "gmusicprocurator/map.jinja" import gmusicprocurator with context -%}
include:
  - .virtualenv
{%- if gmusicprocurator.use_service %}
  - .service
  - .user
{%- else %}
  - .user-config
{%- endif %}
