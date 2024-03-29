class Heroku::Auth
  class << self

    def ask_for_and_save_credentials  # :nodoc:
      begin
        @credentials = ask_for_credentials
        write_netrc
        check
      rescue ::RestClient::Unauthorized, ::RestClient::ResourceNotFound => e
        delete_credentials
        clear
        display "Authentication failed."
        retry if retry_login?
        exit 1
      rescue Exception => e
        delete_credentials
        raise e
      end
      check_for_associated_ssh_key unless Heroku::Command.current_command == "keys:add"
    end

    def delete_credentials # :nodoc:
      netrc.delete("api.#{host}")
      netrc.delete("code.#{host}")
      netrc.save
      @credentials = nil
    end

    def get_credentials   # :nodoc:
      return if @credentials
      if !(@credentials = read_netrc) || (@credentials.last == '!')
        ask_for_and_save_credentials
      end
      @credentials
    end

    def netrc   # :nodoc:
      return @netrc if @netrc
      netrc_path = "#{home_directory}/.netrc"
      unless File.exists?(netrc_path)
        FileUtils.touch(netrc_path)
        FileUtils.chmod(0600, netrc_path)
      end
      begin
        @netrc = Netrc.read(netrc_path)
      rescue Netrc::Error => error
        if error.message =~ /^Permission bits for/
          perm = File.stat(netrc_path).mode & 0777
          abort("Permissions #{perm} for '#{netrc_path}' are too open. You should run `chmod 0600 #{netrc_path}` so that your credentials are NOT accessible by others.")
        else
          raise error
        end
      end
    end

    def read_netrc  # :nodoc:
      netrc["api.#{host}"]
    end

    def write_netrc   # :nodoc:
      netrc["api.#{host}"] = self.credentials
      netrc["code.#{host}"] = self.credentials
      netrc.save
    end

  end
end
