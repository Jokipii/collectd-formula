{% from "collectd/map.jinja" import collectd with context %}
{% set listens = salt['pillar.get']('collectd:plugins:network:listens') %}

include:
  - collectd

{{ collectd.plugindirconfig }}/network.conf:
  file.managed:
    - source: salt://collectd/files/network.conf
    - user: root
    - group: {{ collectd.group }}
    - mode: 644
    - template: jinja
    - watch_in:
      - service: collectd-service
    - defaults:
        servers: {{ salt['pillar.get']('collectd:plugins:network:servers') }}
        listens: {{ listens }}
        ReportStats: {{ salt['pillar.get']('collectd:plugins:network:ReportStats', false) }}

{% if salt['grains.get']('roles:collectd_server') %}
{% for listen in listens %}
{% if listen.AuthFile %}
{{ listen.AuthFile }}:
  file.managed:
    - source: salt://collectd/files/authfile.conf
    - user: root
    - group: {{ collectd.group }}
    - mode: 644
    - template: jinja
    - defaults:
        users: {{ listen.users }}
{% endif %}
{% endfor %}
{% endif %}
