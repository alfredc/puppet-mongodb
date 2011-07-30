# Class: mongodb
#
# This class installs MongoDB (stable)
#
# Notes:
#  This class is Ubuntu specific.
#  Requires apt module
#  By Sean Porter, Gastown Labs Inc., modified by Alfred Chan
#
# Actions:
#  - Install MongoDB using a 10gen Ubuntu repository
#  - Manage the MongoDB service
#  - MongoDB can be part of a replica set
#  - ensure /data/db folder exists
#
# Sample Usage:
#  include mongodb
#
class mongodb {

  apt::source { "mongodb":
    location => "http://downloads-distro.mongodb.org/repo/ubuntu-upstart",
    release => "dist",
    repos => "10gen",
    key => "7F0CEB10",
    key_server => "keyserver.ubuntu.com",
    include_src => false,
  }

  file { "/data/db":
    ensure => directory,
    owner => "root",
    group => "root",
    mode => 644,
  }

	package { "mongodb-10gen":
		ensure => installed,
		require => Apt::Source["mongodb"],
	}

	service { "mongodb":
		enable => true,
		ensure => running,
    hasstatus  => true,
    hasrestart => true,
		require => Package["mongodb-10gen"],
	}

	define replica_set {
		file { "/etc/init/mongodb.conf":
			content => template("mongodb/mongodb.conf.erb"),
			mode => "0644",
			notify => Service["mongodb"],
			require => Package["mongodb-10gen"],
		}
	}
}
