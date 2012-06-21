# netguru gem
Gem designed to take the load of config/deploy.rb

## tasks

### netguru:tag\_release

Tags releases with a timestamp and environment, e.g. 201205161559-production

Usage:
`after('deploy:update_code', 'netguru:tag_release')`

(this is enabled for production stage by default)

### deploy:revert

Rewinds your stage branch to specified timestamp and restarts app.

Usage:
`cap production deploy:revert -s to=201205161559`

## generators

### Pre-commit hook for git

It checks current changes for unwanted stuff (aka *badcode*) and prevents from including it into repository).

In order to install, run this command in the main directory of your app:
`rake netguru:install:precommit`

You don't usually remove this hook, but when you do...
`rake netguru:uninstall:precommit`

## TO DO:
* specs for review response check during reponse
* specs for sc middleware
* use [Konf gem](https://github.com/GBH/konf)
