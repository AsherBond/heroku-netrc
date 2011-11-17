class Heroku::Auth
  class << self

    def ask_for_and_save_credentials  # :nodoc:
      begin
        @credentials = ask_for_credentials
        write_netrc
        check
      rescue ::RestClient::Unauthorized, ::RestClient::ResourceNotFound => e
        # TODO: delete_credentials
        clear
        display "Authentication failed."
        retry if retry_login?
        exit 1
      rescue Exception => e
        # TODO: delete_credentials
        raise e
      end
      check_for_associated_ssh_key unless Heroku::Command.current_command == "keys:add"
    end

    def get_credentials   # :nodoc:
      return if @credentials
      if @credentials = read_credentials
        write_netrc
        FileUtils.rm_f(credentials_file)
      elsif !(@credentials = read_netrc)
        @credentials = ask_for_and_save_credentials
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
      @netrc = Netrc.read(netrc_path)
    end

    def read_netrc  # :nodoc:
      netrc['api.heroku.com']
    end

    def write_netrc   # :nodoc:
      # TODO: include comment about where things came from
      @netrc.new_item_prefix = "\n# Heroku API credentials\n"
      netrc['api.heroku.com'] = self.credentials
      @netrc.new_item_prefix = "\n# Heroku git credentials\n"
      netrc['code.heroku.com'] = self.credentials
      netrc.save
    end

  end
end
