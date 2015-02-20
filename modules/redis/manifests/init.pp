class redis{     
    exec { 'apt-add-repository_redis': 
        path   => "/usr/bin",
        command => 'sudo apt-add-repository -y ppa:rwky/redis'  
    } 
    exec { 'apt-update':                   
        path   => "/usr/bin",
        command => 'sudo apt-get -y update'  
    } 
    package { 'redis-server':
        require => Exec['apt-update'],   
        ensure => installed,
    } 
}