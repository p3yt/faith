exec { 'apt-update-and-upgrade':                   
    path   => "/usr/bin",
    command => 'sudo apt-get -y update && sudo apt-get -y upgrade',
    timeout => '0'  
} 
$enhancers = [ "build-essential", "libssl-dev", "git", "libtool", "libxslt-dev", "libxml2-dev", "libpq-dev", "gawk", "curl", "pngcrush", "imagemagick", "python-software-properties", "sed", "g++", "libreadline6-dev", "zlib1g-dev", "libyaml-dev", "libsqlite3-dev", "sqlite3", "autoconf", "libgdbm-dev", "libncurses5-dev", "automake", "bison", "pkg-config", "libffi-dev", "libcurl4-openssl-dev"]
package { $enhancers: 
    ensure => "installed",
    require => Exec['apt-update-and-upgrade'] 
}

include discourse
include postgre
include redis
include ngix
include rvm
include bluepill
include discourseapp
include conf 