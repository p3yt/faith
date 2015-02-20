class rvm{ 
    require discourse
    $as_discourse = 'sudo -u discourse -H bash -l -c'
         
    exec {'gpg_key':
        path   => ["/usr/bin"],
        command => "${as_discourse} 'gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3'"  
    }
    exec {'install_rvm':
        path   => ["/usr/bin","/bin"],
        command => "${as_discourse} 'curl -L https://get.rvm.io | bash -s stable'", 
        creates => "/home/discourse/.rvm/bin/rvm",
        require => Exec['gpg_key'], 
        #user => "discourse"
    }  
    exec {'install_ruby': 
        path   => ["/usr/bin","/home/discourse/.rvm/bin"],
        command => "${as_discourse} 'rvm install ruby'", 
        creates => "/home/discourse/.rvm/bin/ruby",
        require => Exec['install_rvm'], 
        timeout => "0",
        #user => "discourse"
    } 
    exec { 'bundler':
        path   => ["/usr/bin","/home/discourse/.rvm/rubies/ruby-2.2.0/bin"],
        command => "${as_discourse} 'gem install bundler'", 
        creates => "/home/discourse/.rvm/bin/bundle",
        require => Exec['install_ruby'], 
        timeout => "0",
        #user => "discourse"
    }
}