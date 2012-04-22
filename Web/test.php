<?php
echo "<!DOCTYPE html>\n";
echo "<head>\n";
echo "\t<link rel='stylesheet' type='text/css' href='css/mainstyle.css'/>\n";
echo "</head>\n";
echo "<body>\n";
echo "\t<div id='content'>\n";

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

echo "<ul id='threads'>\n";
if ($result = $db->query("SELECT * FROM thread ORDER BY timestamp Desc")) {
    #printf("Database contains %d threads.\n", $result->num_rows);
    for ($i=0; $i < $result->num_rows; $i++) {
		$thread = $result->fetch_assoc();
		$post_result = $db->query("SELECT * FROM post WHERE thread_id= ". $thread['id'] ." ORDER BY timestamp LIMIT 1");
		$post = $post_result->fetch_assoc();
		
        
		echo "\t\t<li class='post'>\n";
		printf("<a href=thread.php>");
        printf("<img src='%s'/>\n", $post['image_url']);
        printf("</a>");
        $curthread = $i + 1;
        echo "\t\t\tThread #". $curthread . ": " . $post['caption'] . "\n";
        
        echo "\t\t</li>\n";
    }

    $result->close();
}

echo "</ul>\n";

echo "<BR/>" . 'Success... ' . $mysqli->host_info . "\n";

echo "\t</div>\n";
echo "</body>\n";
echo "</html>";


$db->close();
?>