Unifiedpush Server Omnibus
==================================
This project creates full-stack platform-specific packages for `unifiedpush-server`.

Preperation 
------------
only when runing under non root user.

```shell
sudo mkdir -p /opt/unifiedpush-server /var/cache/omnibus
sudo chown USER:USER /opt/unifiedpush
sudo chown USER:USER /var/cache/omnibus
```

Installation
------------
You must have a sane Ruby 1.9+ environment with Bundler installed. Ensure all
the required gems are installed:

```shell
yum -y install gcc ruby-devel rubygems
gem install omnibus
gem install bundler
```

```shell
$ bundle install --without development --binstubs
```

Usage
-----
### Build

You create a platform-specific package using the `build project` command:

```shell
$ bin/omnibus build unifiedpush-server
```

The platform/architecture type of the package created will match the platform
where the `build project` command is invoked. For example, running this command
on a MacBook Pro will generate a Mac OS X package. After the build completes
packages will be available in the `pkg/` folder.

### Clean

You can clean up all temporary files generated during the build process with
the `clean` command:

```shell
$ bin/omnibus clean unifiedpush-server
```

Adding the `--purge` purge option removes __ALL__ files generated during the
build including the project install directory (`/opt/unifiedpush-server`) and
the package cache directory (`/var/cache/omnibus/pkg`):

```shell
$ bin/omnibus clean unifiedpush-server --purge
```

### Publish

Omnibus has a built-in mechanism for releasing to a variety of "backends", such
as Amazon S3. You must set the proper credentials in your `omnibus.rb` config
file or specify them via the command line.

```shell
$ bin/omnibus publish path/to/*.deb --backend s3
```

### Help

Full help for the Omnibus command line interface can be accessed with the
`help` command:

```shell
$ bin/omnibus help
```

Kitchen-based Build Environment
-------------------------------
Every Omnibus project ships will a project-specific
[Berksfile](http://berkshelf.com/) that will allow you to build your omnibus projects on all of the projects listed
in the `.kitchen.yml`. You can add/remove additional platforms as needed by
changing the list found in the `.kitchen.yml` `platforms` YAML stanza.

This build environment is designed to get you up-and-running quickly. However,
there is nothing that restricts you to building on other platforms. Simply use
the [omnibus cookbook](https://github.com/opscode-cookbooks/omnibus) to setup
your desired platform and execute the build steps listed above.

The default build environment requires Test Kitchen and VirtualBox for local
development. Test Kitchen also exposes the ability to provision instances using
various cloud providers like AWS, DigitalOcean, or OpenStack. For more
information, please see the [Test Kitchen documentation](http://kitchen.ci).

Once you have tweaked your `.kitchen.yml` (or `.kitchen.local.yml`) to your
liking, you can bring up an individual build environment using the `kitchen`
command.

```shell
$ bin/kitchen converge ubuntu-1204
```

Then login to the instance and build the project as described in the Usage
section:

```shell
$ bundle exec kitchen login ubuntu-1204
[vagrant@ubuntu...] $ cd unifiedpush-server
[vagrant@ubuntu...] $ bundle install
[vagrant@ubuntu...] $ ...
[vagrant@ubuntu...] $ bin/omnibus build unifiedpush-server
```

For a complete list of all commands and platforms, run `kitchen list` or
`kitchen help`.
