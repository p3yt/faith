class conf{               
    require ngix
    require discourseapp
    exec { 'cp_localserver_conf':
        path   => ["/usr/bin","/bin"],
        command => "sudo cp /opt/discourse/config/nginx.global.conf /etc/nginx/conf.d/local-server.conf", 
        #require => Package['nginx'] 
    }
    exec { 'cp_discourse_conf':
        path   => ["/usr/bin","/bin"],
        command => "sudo cp /opt/discourse/config/nginx.sample.conf /etc/nginx/sites-available/discourse.conf", 
        #require => Package['nginx'] 
    }
    file { '/etc/nginx/sites-available/discourse.conf':
        ensure => present,  
        #require => Package['nginx'] 
    }->
    exec { 'modify_root': 
        path   => ["/usr/bin","/bin"], 
        command => "sudo sed -i 's/\/var\/www\/discourse/\/opt\/discourse/g' /etc/nginx/sites-available/discourse.conf",   
        require => Exec['cp_localserver_conf','cp_discourse_conf'] 
    } ->
    exec { 'modify_servername': 
        path   => ["/usr/bin","/bin"], 
        command => "sudo sed -i 's/server_name.*$/server_name localhost\;/g' /etc/nginx/sites-available/discourse.conf",   
        require => Exec['cp_localserver_conf','cp_discourse_conf']  
    }->
    exec { 'ln_localserver_conf':
        path   => ["/usr/bin","/bin"],
        command => "sudo ln -s /etc/nginx/sites-available/discourse.conf /etc/nginx/sites-enabled/discourse.conf",
        unless =>"test -L /etc/nginx/sites-enabled/discourse.conf",  
        require => Exec['cp_localserver_conf','cp_discourse_conf'] 
    } 
    
    file { '/etc/nginx/nginx.conf':
        ensure => present,
        #require => Package['nginx']  
    }->
    exec { 'include_only_discourse_conf_1': 
        path   => ["/usr/bin","/bin"], 
        command => "sudo sed -i '/conf.d/ s/^/#/g' /etc/nginx/nginx.conf",    
        #require => Package['nginx']  
    }->
    exec { 'include_only_discourse_conf_2': 
        path   => ["/usr/bin","/bin"], 
        command => "sudo sed -i 's/sites-enabled.*$/sites-enabled\/discourse.conf\;/g' /etc/nginx/nginx.conf", 
        #require => Package['nginx']     
    }
    exec { 'restart_ngix': 
        path   => ["/usr/bin","/bin"], 
        command => "sudo /etc/init.d/nginx restart",    
        require => Exec['include_only_discourse_conf_1','include_only_discourse_conf_2','modify_root','modify_servername']
    }
}