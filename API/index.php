<?php

require 'flight/Flight.php';
require_once "php-activerecord/ActiveRecord.php";
require 'controllers/UsersController.php';
ActiveRecord\Config::initialize(function($cfg) {
            $cfg->set_model_directory("models");
            $cfg->set_connections(array(
                "development" => "mysql://db75591_46px:hacknashville@external-db.s75591.gridserver.com/db75591_46px_dev"));
        });


/* * This is the frontend section of the routes. None of the database interaction
 * should happen here; all of the calls to ORM
 */


Flight::route('/user/@id:[0-9]+', array('UsersController', 'user'));

Flight::route('/thread/@id:[0-9]+', function($id) {

            header("Location: http://dev.46px.com/thread.html?id=" . $id);
        });


Flight::route('/post/@id:[0-9]+', function($id) {
            header("Location: http://dev.46px.com/post.html?id=" . $id);
        });

/**
 * This is the backend section of the routes. This section
 * should route to all of the endpoints which spit out data
 * for the html/css/javascript to handle. Eventually, it
 * will be moved to the api section of the website - for
 * testing purposes, it's here for now.  
 */
Flight::route('/api', function() {
            echo 'hello world again!';
        });

Flight::route('/api/user/@id:[0-9]+', function($id) {
            //echo 'UserID:' . $id . "";

            if ($user = User::find($id)) {
                print_r($user->to_json());
            } else {
                print("<p>Cannot find <em>userID(1)</em>.</p>");
            }
        });

Flight::route('/api/thread/@id:[0-9]+', function($id) {
            //echo 'UserID:' . $id . "";

            if ($thread = Thread::find($id)) {
                print_r($thread->to_json());
            } else {
                print("<p>Cannot find <em>userID(1)</em>.</p>");
            }
        });


Flight::route('/api/post/@id:[0-9]+', function($id) {
            //echo 'UserID:' . $id . "";

            if ($post = Post::find($id)) {
                print_r($post->to_json());
            } else {
                print("<p>Cannot find <em>userID(1)</em>.</p>");
            }
        });

Flight::route('/api/stream/top/@pgNum:[0-9]+', function($pgNum) {
            //echo 'UserID:' . $id . "";



            $threads = Thread::recentThreads($pgNum);


            $threads_array;

            
            $test_user_from_post;
            for ($i = 0; $i < 6; $i++) {
                $thread_posts_full = $threads[$i]->post;
                $threads_array[$i] = $threads[$i]->to_array();
                $threads_array[$i]['post'] = $thread_posts_full[0]->to_array();
                $threads_array[$i]['user'] = $thread_posts_full[0]->user->to_array();
                // $test_user_from_post[$i] = $thread_posts_full[0]->user->to_array();
            }
            
            
            $stream ['threads'] = $threads_array;
            
            
            $json_data = json_encode($stream);
            
            //$json_data_users = json_encode($test_user_from_post);

            print_r($json_data);

        });
        
        Flight::route('/api/stream/user/@pgNum:[0-9]+', function($pgNum) {
            //echo 'UserID:' . $id . "";



            $threads = Thread::recentThreads($pgNum);


            $threads_array;

            
            $test_user_from_post;
            for ($i = 0; $i < 6; $i++) {
                $thread_posts_full = $threads[$i]->post;
                $threads_array[$i] = $threads[$i]->to_array();
                $threads_array[$i]['post'] = $thread_posts_full[0]->to_array();
                $threads_array[$i]['user'] = $thread_posts_full[0]->user->to_array();
                // $test_user_from_post[$i] = $thread_posts_full[0]->user->to_array();
            }
            
            
            $stream ['threads'] = $threads_array;
            
            
            $json_data = json_encode($stream);
            
            //$json_data_users = json_encode($test_user_from_post);

            print_r($json_data);

        });
Flight::start();
?>
