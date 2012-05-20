<?php

    session_start();

	$db = new mysqli('external-db.s75591.gridserver.com', 'db75591_46px','hacknashville', 'db75591_46px');
    /*
     * This is the "official" OO way to do it,
     * BUT $connect_error was broken until PHP 5.2.9 and 5.3.0.
     */
    if ($db->connect_error) {
        die('Connect Error (' . $db->connect_errno . ') '
            . $db->connect_error);
    }
    /*
     * Use this instead of $connect_error if you need to ensure
     * compatibility with PHP versions prior to 5.2.9 and 5.3.0.
     */
    if (mysqli_connect_error()) {
        die('Connect Error (' . mysqli_connect_errno() . ') '
            . mysqli_connect_error());
    }


	$fields = $_GET['46px_user_id'] ."', '". $_GET['post_id'];

    if ($db->query("SELECT * FROM like_list WHERE user_id='".$_GET['46px_user_id']."' AND post_id='".$_GET['post_id']."'")->num_rows == 0) {
        $db->query("INSERT INTO like_list (user_id, post_id) VALUES('$fields') ") or die (mysql_error());
    } else {
        $db->query("DELETE FROM like_list WHERE user_id ='".$_GET['46px_user_id']."' AND post_id ='".$_GET['post_id']."'");
    }

	header("Location: http://46px.com/thread.php?thread=" . $_GET['thread_id']."&46px_user_id=".$_GET["46px_user_id"]);
    ?>