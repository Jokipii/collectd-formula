{% from "collectd/map.jinja" import collectd with context %}

include:
  - collectd.service

collectd:
  pkg.installed:
    - name: {{ collectd.pkg }}

{{ collectd.plugindirconfig }}:
  file.directory:
    - user: root
    - group: {{ collectd.group }}
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - require_in:
      - service: collectd-service # set proper file mode before service runs

{{ collectd.config }}:
  file.managed:
    - source: salt://collectd/files/collectd.conf
    - user: root
    - group: {{ collectd.group }}
    - mode: 644
    - template: jinja
    - watch_in:
      - service: collectd-service
    - defaults:
        hostname: {{ salt['grains.get']('fqdn') }}
        FQDNLookup: {{ salt['pillar.get']('collectd:FQDNLookup', 'false') }}
        BaseDir: {{ salt['pillar.get']('collectd:BaseDir', '/var/lib/collectd') }}
        PluginDir: {{ salt['pillar.get']('collectd:PluginDir', '/var/lib/collectd') }}
        types: {{ salt['pillar.get']('collectd:TypesDB', ['/usr/share/collectd/types.db']) }}
        AutoLoadPlugin: {{ salt['pillar.get']('collectd:AutoLoadPlugin', false) }}
        Interval: {{ salt['pillar.get']('collectd:Interval', 10) }}
        Timeout: {{ salt['pillar.get']('collectd:Timeout', 2) }}
        ReadThreads: {{ salt['pillar.get']('collectd:ReadThreads', 5) }}
        WriteThreads: {{ salt['pillar.get']('collectd:WriteThreads', 5) }}
        WriteQueueLimitHigh: {{ salt['pillar.get']('collectd:WriteQueueLimitHigh', 1000000) }}
        WriteQueueLimitLow: {{ salt['pillar.get']('collectd:WriteQueueLimitLow', 800000) }}
        default: {{ salt['pillar.get']('collectd:plugins:default') }}
        plugindirconfig: {{ collectd.plugindirconfig }}
        plugins: {{ salt['pillar.get']('collectd:plugins:enable', false) }}
