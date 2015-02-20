class ngix{     
    exec { 'apt-add-repository_ngix':    
        path   => "/usr/bin",                
        command => 'sudo apt-add-repository -y ppa:nginx/stable' 
    }  
    package { 'nginx':
        require => Exec['apt-update'],  
        ensure => installed,
    }
    notify { 'nginx is installed.':
    }
    file { ["/var/nginx","/var/nginx/cache"]:
        ensure => "directory",
        owner  => "root",
        group  => "root",
        mode   => 755,
        recurse => true,
        require => Package['nginx'] 
    } 
}