require "heroku/command/base"

class Heroku::Command::Ssh < Heroku::Command::Base

  # ssh DYNO
  #
  # ssh into a running dyno
  #
  # Dynos are uniquely identified by their `hostname`. Example:
  #
  # $ heroku run hostname
  # Running `hostname` attached to terminal... up, run.1
  # dce6fdfd-4590-486d-800e-40042089e48c
  #
  # In order to ssh into a running dyno, its UUID is required. A possible way to
  # obtain those identifiers is to print them to stdout and make them available
  # in `heroku logs`.
  #
  def index
    hostname = args.shift
    error("Please specify a dyno hostname UUID. The uuid can be determined with `hostname` inside a dyno.") unless hostname
    rendezvous = File.expand_path(File.join(File.dirname(__FILE__), "bin/rendezvous"))
    exec("ssh", "-o", "ProxyCommand=#{rendezvous} #{hostname}", "-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null", "dyno@#{hostname}")
  end

  # ssh:keys
  #
  # Display public keys currently allowed to ssh into dynos.
  #
  def keys
    authorized_keys = api.get_config_vars(app).body["AUTHORIZED_KEYS"].to_s.strip
    return display "No public keys currently authorized" if authorized_keys.empty?
    display authorized_keys
  end

  # ssh:authorize [FILENAME]
  #
  # Authorize a new public key to ssh into dynos. FILENAME is `~/.ssh/id_rsa.pub`
  # by default.
  #
  # New keys are prepended to the `AUTHORIZED_KEYS` config var. See `heroku
  # help config` for more details on how to manipulate it.
  #
  def authorize
    key_file = args.shift || File.join(Dir.home, ".ssh", "id_rsa.pub")
    authorized_keys = api.get_config_vars(app).body["AUTHORIZED_KEYS"].to_s.strip
    key = File.read(key_file).strip
    return(display "The key found in #{key_file} is already authorized.") if
      authorized_keys.include?(key)

    display "Authorizing the key present in #{key_file}...", false
    api.put_config_vars(app, "AUTHORIZED_KEYS" => "#{key}\n#{authorized_keys}")
    display " done"
  end

end
