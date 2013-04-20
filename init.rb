require "heroku/command/base"

class Heroku::Command::Ssh < Heroku::Command::Base

  # ssh
  #
  # ssh into a running dyno
  #
  def index
    hostname = args.shift
    error("Please specify a dyno hostname UUID. The uuid can be determined with `hostname` inside a dyno.") unless hostname
    rendezvous = File.expand_path(File.join(File.dirname(__FILE__), "bin/rendezvous"))
    exec("ssh", "-o", "ProxyCommand=#{rendezvous} #{hostname}", "-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null", "dyno@#{hostname}")
  end

end
