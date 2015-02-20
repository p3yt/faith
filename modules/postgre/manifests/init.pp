class postgre{
    $as_postgre = "sudo -u postgres"
    $pg_user = "postgres"
    exec  { 'installpostgre':
        path    => '/usr/bin',
        command => 'sudo apt-get -y install postgresql postgresql-contrib',
        timeout => '0'
    } 
    exec  { 'createuser':
        path   => ["/usr/bin","/bin"], 
        command => "${as_postgre} createuser -s discourse", 
        unless => "${as_postgre}  psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='discourse'\" | grep -q 1",
        require => Exec['installpostgre'] 
    } 
    exec  { 'createpwd':
        path   => "/usr/bin",
        command => "psql -c \"alter user discourse password 'discourse';\"",  
        require => Exec['createuser'],
        user => $pg_user
    }
}