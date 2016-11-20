salt:
  master:
    fileserver_backend:
      - roots
    file_roots:
      base:
        - /srv/salt/current/salt
    pillar_roots:
      base:
        - /srv/salt/current/pillar

  minion:
    master: {{ pillar.trusted.fqdn }}
