<?php
	
  session_start();
  $accessToken = $_GET['accessToken'];
  $userID = $_GET['id'];


  //setcookie('46px_user_id', $userID);
  //print_r($_COOKIES);
  $_SESSION['46px_user_id']=$userID;

  print_r($_SESSION);
  

  $userURL = "http://graph.facebook.com/". $userID . "?accessToken=" . $accessToken;





$ch = curl_init();
$timeout = 5; // set to zero for no timeout
curl_setopt ($ch, CURLOPT_URL, $userURL);
curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt ($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
$file_contents = curl_exec($ch);
curl_close($ch);

$userDict = json_decode($file_contents);
$first_name = $userDict->first_name;
$last_name = $userDict->last_name;
$id = $userDict->id;


	
	$db = new mysqli('external-db.s75591.gridserver.com', 'db75591_46px','hacknashville', 'db75591_46px');
	if ($db->connect_error) {
    	die('Connect Error (' . $db->connect_errno . ') '
            . $db->connect_error);
	}
	if (mysqli_connect_error()) {
        die('Connect Error (' . mysqli_connect_errno() . ') '
            . mysqli_connect_error());
    }


   
 if($result = $db->query("REPLACE INTO users (id, first_name, last_name) VALUES ('$userID', '$first_name', '$last_name')"))
 {
 	print_r($result);
 }
 else
 {
 	echo $db->error;
 }

 ?>