<?php
require 'flight/Flight.php';
require_once "php-activerecord/ActiveRecord.php";
    ActiveRecord\Config::initialize(function($cfg) {
        $cfg->set_model_directory("models");
        $cfg->set_connections(array(
            "development" => "mysql://db75591_46px:hacknashville@external-db.s75591.gridserver.com/db75591_46px_dev"));
    });

Flight::route('/', function(){
    echo 'hello world again!';
});

Flight::route('/user/@id:[0-9]+', function($id){
    //echo 'UserID:' . $id . "";
    
    if ($user = Users::find($id)) {
        print_r($user->to_json());
    } else {
        print("<p>Cannot find <em>userID(1)</em>.</p>");

    }
});

Flight::route('/thread/@id:[0-9]+', function($id){
    //echo 'UserID:' . $id . "";
    
    if ($thread = Threads::find($id)) {
        print_r($thread->to_json());
    } else {
        print("<p>Cannot find <em>userID(1)</em>.</p>");

    }
});


Flight::route('/post/@id:[0-9]+', function($id){
    //echo 'UserID:' . $id . "";
    
    if ($post = Posts::find($id)) {
        print_r($post->to_json());
    } else {
        print("<p>Cannot find <em>userID(1)</em>.</p>");

    }
});
Flight::start();
?>
