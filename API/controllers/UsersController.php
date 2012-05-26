<?php

require_once "php-activerecord/ActiveRecord.php";

ActiveRecord\Config::initialize(function($cfg) {
            $cfg->set_model_directory("models");
            $cfg->set_connections(array(
                "development" => "mysql://db75591_46px:hacknashville@external-db.s75591.gridserver.com/db75591_46px_dev"));
        });

class UsersController {

    public static function user($idNum) {
        
        echo"hello : " . $idNum . "";

        if ($user = Users::find($idNum)) {
            print_r($user->to_json());
        }
        else
        {
            echo"awwww";
        }
        echo "done";
    }

}

?>
