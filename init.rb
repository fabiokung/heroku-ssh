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

end
