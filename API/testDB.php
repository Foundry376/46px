<html>
<head>
    <title>Getting started with open source PHP ActiveRecord ORM library</title>
</head>
<body>
 
<?php
 // Configure PHP ActiveRecord and specify our "models/" subdirectory.
    require_once "php-activerecord/ActiveRecord.php";
    require 'flight/Flight.php';
    //Flight::start();
    ActiveRecord\Config::initialize(function($cfg) {
        $cfg->set_model_directory("models");
        $cfg->set_connections(array(
            "development" => "mysql://db75591_46px:hacknashville@external-db.s75591.gridserver.com/db75591_46px_dev"));
    });
 
    // Create a new record in the Users table, and specify a userName and userEmail.
     //$user = Users::create(array("id" => "1", "first_name" => "Test","last_name" => "User", "picUrl" => "http://images2.wikia.nocookie.net/__cb20091229130906/wario/images/d/d6/Bowser-jr-test.png"));
    // Return record with primary ID of 3.
    if ($user1 = Users::find(1)) {
        print("<p>" . $user1->first_name . $user1->last_name . "</p>");
    } else {
        print("<p>Cannot find <em>userID(1)</em>.</p>");
    }
    
//   Flight::route('/', function(){
//    echo 'hello world!';
//});
 
?>
 
</body>
</html>