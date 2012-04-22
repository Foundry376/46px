<?php 

// connect to the database!
$db = new mysqli('external-db.s75591.gridserver.com', 'db75591_46px','hacknashville', 'db75591_46px');
if ($db->connect_error) {
	die('Connect Error (' . $db->connect_errno . ') '
	. $db->connect_error);
}
if (mysqli_connect_error()) {
	die('Connect Error (' . mysqli_connect_errno() . ') '
	. mysqli_connect_error());
}

// grab all our variables... and sanitize them ;-)
$id = mysql_escape_string($_POST["userID"]);
$caption = mysql_escape_string($_POST["caption"]);
$threadID = mysql_escape_string($_POST["threadID"]);
$file = $_FILES["image"];

$dirName = "users/" . $id . "/";
@mkdir($dirName, 0777, true);

$dirName = $dirName . md5_file($file['tmp_name']).".png";

if (move_uploaded_file($file['tmp_name'], $dirName)) {
	//echo "File is valid, and was successfully uploaded.\n";
} else {
	//echo "Possible file upload attack!\n";
}

$dirName = "/" . $dirName;

// are we appending this to an existing thread?
if ($threadID == -1) {
	// we need to create a new thread for this post!
	$result = $db->query("INSERT INTO thread (timestamp) VALUES (NOW());");
	$threadID = mysqli_insert_id($db);
}

if($result = $db->query("INSERT INTO post (thread_id,user_id,caption,image_url) VALUES ('$threadID', '$id', '$caption', '$dirName')"))
{
	echo "http://www.46px.com/thread.php?thread=".$threadID;
}
else
{
	echo $db->error;
}

 ?>