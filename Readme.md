# SSH-able dynos

## Installation

```term
heroku plugins:install https://github.com/fabiokung/heroku-ssh.git
```

## Requirements

Heroku dynos need to be **tagged** as ssh-able. This means that they need to run
a special agent (daemon) to enable ssh connectivity.

There is a [pre-built binary](https://s3.amazonaws.com/heroku-sshable/v0.1.0/sshable)
of the agent to be used inside heroku (linux-x86_64). The source code is also
[available on github](https://github.com/fabiokung/sshable).

First, add the binary to your application's bin directory and push it:

```term
cd app
mkdir -p bin
cd bin
wget https://s3.amazonaws.com/heroku-sshable/v0.1.0/sshable
chmod +x sshable
cd ..
git push heroku master
```

After it is deployed, test your ssh connection:

```term
$ heroku run sshable bash
Running `sshable bash` attached to terminal... up, run.1
(dyno) ~ $ hostname
DYNO_UUID # this will be an UUIDv4 string to be used later
```

Then, in a different terminal:

```term
$ heroku ssh DYNO_UUID
```

## Usage

Each dyno has its own unique identifier, available as `hostname` inside them.
`heroku ssh` requires these ids, but unfortunately it is not yet possible to
retrieve them via the heroku API (or CLI).

A possible way to expose them is with custom logic to apps, printing `hostname`
to `stdout`. That will cause dyno uuids to be available in `heroku logs`.
Alternatively, each dyno can register itself in a stable service or datastore
(heroku add-ons, redis, postgresql, etc).

Once uuids are available somehow, ssh support needs to be enabled for each
process type by adding `sshable` to Procfile entries:

```javascript
web: bundle exec rackup -p $PORT
worker: sshable bundle exec sidekiq
```

In this case, one can ssh into `worker` dynos with:

```term
heroku ssh WORKER_UUID
```

## Known issues

* No concurrent connections. Currently only a single connection is supported.
* Dynos will stop accepting new connections for 10s after one terminates.
* Lack of visibility on errors.
* Alpha stage.
* Dyno uuids not available in the heroku API (eg.: `heroku ps` could list them).

