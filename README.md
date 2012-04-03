# netguru gem
Gem designed to take the load of config/deploy.rb

## generators

### Pre-commit hook for git

It checks current changes for unwanted stuff (aka *badcode*) and prevents from including it into repository).

In order to install, run this command in the main directory of your app:
`rake netguru:install:precommit`

You don't usually remove this hook, but when you do...
`rake netguru:uninstall:precommit`

## TO DO:
* specs for secondcoder response check during reponse
* specs for sc middleware
* use [Konf gem](https://github.com/GBH/konf)
