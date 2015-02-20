class discourse{    
    $discourse_user   = 'discourse'
    $db_name          = 'discourse_prod'
    $db_user          = 'discourse'
    $db_user_password = 'discourse'
    $db_host          = 'localhost'
    $ensure_present   = 'present'
    $vm_groups        = ['sudo'] 
    user { $discourse_user:
        name       => $discourse_user,
        ensure     => $ensure_present, 
        groups     => $vm_groups,
        shell      => '/bin/bash', 
        home       => '/home/discourse',
        comment    => 'Discourse application',
        managehome => true,
        password   => '*'
    } 
    file { "/opt/discourse":
        ensure => "directory",
        owner  => $discourse_user,
        group  => $discourse_user,
        mode   => 755
    } 
} 
