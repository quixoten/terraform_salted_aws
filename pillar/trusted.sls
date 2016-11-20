#!py

# This file uses the trusted minion id to create a trusted set of pillar
# data.

# All id's should be in the form of site-env-serviceX, where "X" is a number
# starting at 1.
#
# Valid Examples:
#   aws-dev-salt1
#   aws-dev-web1
#   aws-int-web2
#   us_east_1-prod-db20
#
# Because a dash is used as a separator, it cannot be used in the site, env, or
# service identifiers. Using the examples above and the default DOMAIN and
# ENVIRONMENTS, here's table showing all the data extracted from each trusted
# minion id:
#
# | minion_id           | domain      | env  | environment | fqdn                                 | hostname            | number | padded_number | service | site      | site_env      |
# |---------------------|-------------|------|-------------|--------------------------------------|---------------------|--------|---------------|---------|-----------|---------------|
# | aws-dev-salt1       | example.com | dev  | development | aws-dev-salt1.dev.example.com        | aws-dev-salt1       | 1      | 001           | salt    | aws       | aws-dev       |
# | aws-dev-web1        | example.com | dev  | development | aws-dev-web1.dev.example.com         | aws-dev-web1        | 1      | 001           | web     | aws       | aws-dev       |
# | aws-int-web2        | example.com | int  | integration | aws-int-web2.int.example.com         | aws-int-web2        | 2      | 002           | web     | aws       | aws-int       |
# | us_east_1-prod-db20 | example.com | prod | production  | us_east_1-prod-db20.prod.example.com | us_east_1-prod-db20 | 20     | 020           | db      | us_east_1 | us_east_1-dev |
#
# The duplication of the env in the fqdn is done so that the hostname can be
# used as a complete identifier while still allowing DNS zones to be managed
# per env.

import re

DOMAIN       = "example.com"
ENVIRONMENTS = { "dev":  "development"
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
