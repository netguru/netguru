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

### Hooks for git (`git_hooks`)

  * `post-merge` - show message if changes in `Gemfile`/`Gemfile.lock` or `schema.rb` have been detected so user can spot it and run `bundle`/`rake db:migrate`

In order to install:

    rails generate netguru:git_hooks

## TO DO:
* specs for review response check during reponse
* specs for sc middleware
* use [Konf gem](https://github.com/GBH/konf)
