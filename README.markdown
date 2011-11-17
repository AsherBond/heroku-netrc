# Heroku netrc

Uses netrc files to store Heroku credentials.

## Installation

    $ heroku plugins:install git://github.com/geemus/heroku-netrc.git

## Usage

NOTE: This plugin is incompatible with the heroku-accounts plugin.

After installation the plugin should work seamlessly. It will either convert existing credentials to being stored in netrc format or record new credentials in this format when they are added.
