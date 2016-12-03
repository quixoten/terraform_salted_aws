#!py

# This file uses the trusted minion id to create a trusted set of pillar
# data.
#
#
# All minion ID's should be in the form of:
#     {{ site }}-{{ env }}-{{ service }}{{ number }}
#
#
# where {{ number }} is a number starting at 1. Because a dash is used as a
# separator, a dash cannot be used in the site, env, or service identifiers.
# Because the minion ID is also used as the node's hostname, it can only
# include a letter, followed by letters, numbers, and dashes.
#
#
# Valid minion ID's are:
#     aws-dev-salt1
#     aws2-dev-web1
#     aws-int-web2
#     uswest2b-prod-db20
#     site1-prod-lb1
#     sa-test-lb3
#
#
# Invalid minion ID's are:
#     2ndsite-dev-web1     # cannot begin with a number
#     us-west-2b-prod-lb1  # cannot include more than two dashes
#     us_west_2b-prod-lb1  # cannot include underscore
#
#
# Using the valid examples above and the default DOMAIN and ENVIRONMENTS,
# here's a table showing all the data extracted from each trusted minion id:
#
# | minion_id          | domain      | env  | environment | fqdn                                | hostname           | number | padded_number | service | site     | site_env     |
# |--------------------|-------------|------|-------------|-------------------------------------|--------------------|-------:|--------------:|---------|----------|--------------|
# | aws-dev-salt1      | example.com | dev  | development | aws-dev-salt1.dev.example.com       | aws-dev-salt1      |      1 |           001 | salt    | aws      | aws-dev      |
# | aws2-dev-web1      | example.com | dev  | development | aws2-dev-web1.dev.example.com       | aws2-dev-web1      |      1 |           001 | web     | aws2     | aws2-dev     |
# | aws-int-web2       | example.com | int  | integration | aws-int-web2.int.example.com        | aws-int-web2       |      2 |           002 | web     | aws      | aws-int      |
# | uswest2b-prod-db20 | example.com | prod | production  | uswest2b-prod-db20.prod.example.com | uswest2b-prod-db20 |     20 |           020 | db      | uswest2b | uswest2b-dev |
# | site1-prod-lb1     | example.com | prod | production  | site1-prod-lb1.prod.example.com     | site1-prod-lb1     |      1 |           001 | lb      | site1    | site1-dev    |
# | sa-prod-lb3        | example.com | prod | production  | sa-prod-lb1.prod.example.com        | sa-prod-lb3        |      3 |           003 | lb      | sa       | sa-dev       |
#
#
# The duplication of the env in the fqdn is done so that the hostname can be
# used as a globally unique identifier while still allowing DNS zones to be
# managed per env.

import re

DOMAIN       = "example.com"
ENVIRONMENTS = { "dev":  "development"
               , "test": "testing"
               , "int":  "integration"
               , "prod": "production"
               }

def run():
  minion_id   = __opts__["id"]
  match       = re.match("^([^-.]+)-([^-.]+)-([^\d.-]+)(\d+)", minion_id)
  site        = match.group(1)
  env         = match.group(2)
  service     = match.group(3)
  number      = int(match.group(4))
  environment = ENVIRONMENTS[env]
  site_env    = "{site}-{env}".format(site=site, env=env)
  hostname    = "{site_env}-{service}{number}".format(site_env=site_env, service=service, number=number)
  domain      = "{env}.{domain}".format(env=env, domain=DOMAIN)
  fqdn        = "{hostname}.{domain}".format(hostname=hostname, domain=domain)

  return { "trusted": { "domain":           domain
                      , "env":              env
                      , "environment":      environment
                      , "fqdn":             fqdn
                      , "hostname":         hostname
                      , "number":           number
                      , "padded_number":    "{:03d}".format(number)
                      , "service":          service
                      , "site":             site
                      , "site_env":         site_env
                      }
         , "include": [ "service.{0}".format(service) ]
         }

# :vim set ft=python :
