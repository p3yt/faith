class discourseapp{     
    require discourse
    require postgre
    require bluepill
    $as_discourse = 'sudo -u discourse -H bash -l -c'
    exec { 'clone_git': 
        path   => ["/usr/bin","/bin"],
        command => "${as_discourse} 'git clone git://github.com/discourse/discourse.git .'",
        #command => "git clone git://github.com/discourse/discourse.git .",
        onlyif => "test ! \"$(ls -A /opt/discourse)\"",
        cwd     => "/opt/discourse", 
        timeout => "0"  , 
        #user => "discourse" 
    }
    exec { 'install_bundle': 
        path   => ["/usr/bin","/home/discourse/.rvm/gems/ruby-2.2.0/bin"],
        command => "${as_discourse} 'bundle install --deployment --without test'",  
        #command => "bundle install --deployment --without test",  
        cwd     => "/opt/discourse", 
        timeout => "0" , 
        #user => "discourse" 
    }
    exec { 'copy_conf_file': 
        path   => ["/usr/bin","/bin"],
        cwd     => "/opt/discourse", 
        command => "${as_discourse} 'cp config/discourse_quickstart.conf config/discourse.conf'", 
        #command => "cp config/discourse_quickstart.conf config/discourse.conf", 
        require => Exec['clone_git','install_bundle'] , 
        #user => "discourse"   
    } 
    exec { 'copy_pill_file': 
        path   => ["/usr/bin","/bin"],
        cwd     => "/opt/discourse", 
        command => "${as_discourse} 'cp config/discourse.pill.sample config/discourse.pill'", 
        #command => "cp config/discourse.pill.sample config/discourse.pill", 
        require => Exec['clone_git','install_bundle'] , 
        #user => "discourse"    
    } 
    exec { 'modify_hostname': 
        path   => ["/usr/bin","/bin"], 
        command => "${as_discourse} \"sed -i 's/^hostname.*$/hostname = \\\"localhost\\\"/g' /opt/discourse/config/discourse.conf\"",   
        #command => "sed -i 's/^hostname.*$/hostname = \\\"localhost\\\"/g' /opt/discourse/config/discourse.conf",   
        require => Exec['copy_conf_file','copy_pill_file'] , 
        #user => "discourse" 
    } 
    exec { 'modify_db_username': 
        path   => ["/usr/bin","/bin"], 
        command => "${as_discourse} \"sed -i 's/^\#.*db_username.*$/db_username = discourse/g' /opt/discourse/config/discourse.conf\"",   
        #command => "sed -i 's/^\#.*db_username.*$/db_username = discourse/g' /opt/discourse/config/discourse.conf",   
        require => Exec['copy_conf_file','copy_pill_file'] , 
        #user => "discourse"  
    } 
    exec { 'modify_db_pwd': 
        path   => ["/usr/bin","/bin"], 
        command => "${as_discourse} \"sed -i 's/^\#.*db_password.*$/db_password = discourse/g' /opt/discourse/config/discourse.conf\"",   
        #command => "sed -i 's/^\#.*db_password.*$/db_password = discourse/g' /opt/discourse/config/discourse.conf",   
        require => Exec['copy_conf_file','copy_pill_file'] , 
        #user => "discourse" 
    } 
    ###############################################################################
    exec { 'createdb': 
        path   => ["/usr/bin","/bin"],
        cwd     => "/opt/discourse", 
        command => "${as_discourse} 'createdb discourse_prod'",       
        #command => "createdb discourse_prod",       
        unless => "${as_discourse} 'psql -l | grep discourse_prod'",
        #unless => "psql -l | grep discourse_prod",
        require => Exec['modify_db_username','modify_db_pwd'] , 
        #user => "discourse" 
    }
    exec { 'db_migrate': 
        path   => ["/usr/bin"],
        cwd     => "/opt/discourse", 
        command => "${as_discourse} 'RUBY_GC_MALLOC_LIMIT=90000000 RAILS_ENV=production bundle exec rake db:migrate'",      
        #command => "RUBY_GC_MALLOC_LIMIT=90000000 RAILS_ENV=production bundle exec rake db:migrate",      
        require => Exec['modify_db_username','modify_db_pwd'],
        timeout => "0" , 
        #user => "discourse" 
    }
    exec { 'assets_precompile': 
        path   => ["/usr/bin"],
        cwd     => "/opt/discourse", 
        command => "${as_discourse} 'RUBY_GC_MALLOC_LIMIT=90000000 RAILS_ENV=production bundle exec rake assets:precompile'",    
        #command => "RUBY_GC_MALLOC_LIMIT=90000000 RAILS_ENV=production bundle exec rake assets:precompile",    
        require => Exec['modify_db_username','modify_db_pwd'], 
        timeout => "0" , 
        #user => "discourse" 
    }
    exec { 'load_bluepill': 
        path   => ["/usr/bin"],
        cwd     => "/opt/discourse", 
        command => "${as_discourse} 'RUBY_GC_MALLOC_LIMIT=90000000 RAILS_ROOT=/opt/discourse RAILS_ENV=production NUM_WEBS=2 bluepill --no-privileged -c ~/.bluepill load /opt/discourse/config/discourse.pill'",      
        #command => "RUBY_GC_MALLOC_LIMIT=90000000 RAILS_ROOT=/opt/discourse RAILS_ENV=production NUM_WEBS=2 bluepill --no-privileged -c ~/.bluepill load /opt/discourse/config/discourse.pill",      
        require => Exec['modify_db_username','modify_db_pwd'], 
        timeout => "0" , 
        #user => "discourse" 
    }
}