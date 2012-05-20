<?php
require 'flight/Flight.php';

Flight::route('/', function(){
    echo 'hello world again!';
});

Flight::route('/user/@id:[0-9]+', function($id){
    
    header("Location: http://dev.46px.com/user.html?id=" . $id);
    

});

Flight::route('/thread/@id:[0-9]+', function($id){
    
    header("Location: http://dev.46px.com/thread.html?id=" . $id);
  
});


Flight::route('/post/@id:[0-9]+', function($id){
    header("Location: http://dev.46px.com/post.html?id=" . $id);

});
Flight::start();
?>
