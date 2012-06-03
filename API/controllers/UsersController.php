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

	#Returns the number of posts that a given user has created. 
	public static function numPosts($idNum){
		$num = Posts::count(array('conditions' => 'user_id = '. $idNum));
		echo $num;
	}


	#Returns the number of Likes a user has made. 
	public static function numLikes($idNum){
		#static $table_name = "like_lists";
		$num = Like_list::count(array('conditions' => 'user_id = '. $idNum));
		echo $num;
	}

	#We can't actually do this function until we add a joinDate field to our db.
	#public static function joinDate($idNum)
}

?>
