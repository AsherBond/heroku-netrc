require 'fileutils'
require 'vendor/netrc'

require 'heroku/auth'
require 'netrc/heroku/auth'

# convert to .netrc from old at install time
if Heroku::Auth.credentials = Heroku::Auth.read_credentials
  Heroku::Auth.write_netrc
  FileUtils.rm_f(Heroku::Auth.credentials_file)
  if Heroku::Auth.credentials.last.length > 40
    display <<-WARNING
 !    You have an old API key which may be incompatible with tools such as curl.
 !    Fix this by clicking 'Regenerate' at:
 !    https://api.#{Heroku::Auth.host}/account
WARNING
  end
end
