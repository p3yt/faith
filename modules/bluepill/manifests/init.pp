class bluepill{     
    require discourse
    require rvm
    $as_discourse = 'sudo -u discourse -H bash -l -c'
    exec { 'install_bluepill': 
        path   => ["/usr/bin","/home/discourse/.rvm/rubies/ruby-2.2.0/bin"],
        command => "${as_discourse} 'gem install bluepill'", 
        #command => "gem install bluepill", 
        timeout => "0",
        #user => "discourse"
    }

    file { '/home/discourse/.bashrc':
    ensure => present,
    }->
    exec { 'add_to_bash': 
        path   => ["/bin","/usr/bin"],
        command => "${as_discourse} \"echo 'alias bluepill=\\\"NOEXEC_DISABLE=1 bluepill --no-privileged -c ~/.bluepill\\\"' >> ~/.bashrc\"",
        require => Exec['install_bluepill'] ,
        #user => "discourse" 
    }
    # file_line { 'Append a line to /home/discourse/.bashrc':
    # path => '/home/discourse/.bashrc',  
    # line => 'alias bluepill="NOEXEC_DISABLE=1 bluepill --no-privileged -c ~/.bluepill"',
    # }
   
    exec { 'blue_pill_bootupwrapper': 
        path   => ["/bin","/usr/bin","/home/discourse/.rvm/bin"],
        command => "${as_discourse} 'rvm wrapper $(rvm current) bootup bluepill'",
        #command => "rvm wrapper $(rvm current) bootup bluepill",
        require => Exec['install_bluepill'] ,
        #user => "discourse" 
    } 
    #,"${as_discourse} 'rvm wrapper $(rvm current) bootup bundle'"]
    exec { 'bundle_bootupwrapper': 
        path   => ["/bin","/usr/bin"],
        command => "${as_discourse} 'rvm wrapper $(rvm current) bootup bundle'",
        #command => "rvm wrapper $(rvm current) bootup bundle",
        #require => Exec['install_ruby'] ,
        require => Exec['install_bluepill'] ,
        #user => "discourse" 
    } 
    cron { 'blue_pill_cron':
        command => "@reboot RUBY_GC_MALLOC_LIMIT=90000000 RAILS_ROOT=/opt/discourse RAILS_ENV=production NUM_WEBS=2 /home/discourse/.rvm/bin/bootup_bluepill --no-privileged -c ~/.bluepill load /opt/discourse/config/discourse.pill",
        require => Exec['install_bluepill'] ,
        user    => "discourse", 
    }

}