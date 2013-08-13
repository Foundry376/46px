<!DOCTYPE html>
<head>
<link rel='stylesheet' type='text/css' href='css/mainstyle.css'/>
</head>
<body>
<div id='content'>

<script language="javascript">
	var zoom = 5;
</script>
<script src="js/images.js" language="javascript"></script>
	
<?
$db = new mysqli('external-db.s75591.gridserver.com', 'db75591_46px','hacknashville', 'db75591_46px');
if ($db->connect_error) {
    die('Connect Error (' . $db->connect_errno . ') ' . $db->connect_error);
}

if (mysqli_connect_error()) {
    die('Connect Error (' . mysqli_connect_errno() . ') ' . mysqli_connect_error());
}

// Check to see if there is a page number
if (!(isset($_GET['pagenum'])))
	$pagenum=1;
else
	$pagenum = $_GET['pagenum'];

if ($pagenum < 1) $pagenum = 1;

$num_per_page = 30; // The number of threads to be shown per page
$currentpage = $_SERVER["PHP_SELF"]."?46px_user_id=".$_GET["46px_user_id"]."&mine=".$_GET["mine"];

// Sets the range of the query
$max = 'LIMIT ' .($pagenum - 1)* $num_per_page . ',' . $num_per_page;

if ($_GET['mine'] == true) {
	$mine = true;
	$count_query = "SELECT COUNT(*) as count FROM post WHERE user_id = ".mysql_escape_string($_GET['46px_user_id'])." GROUP BY post.thread_id";
	$thread_query = "SELECT thread_id as id FROM post WHERE user_id = ".mysql_escape_string($_GET['46px_user_id'])." GROUP BY post.thread_id ORDER BY timestamp DESC " . $max;
} else {
	$mine = false;
	$count_query = "SELECT COUNT(*) as count FROM thread";
	$thread_query = "SELECT * FROM thread ORDER BY timestamp DESC " . $max;
}

$query = $db->query($count_query) or die(mysql_error());
$query_row = $query->fetch_assoc();
$last_page_num = ceil($query_row['count'] / $num_per_page);


if ($mine) {
	echo '<div class="note"><div>Showing drawings you posted or replied to. <a href="index.php?45px_user_id='.$_GET["46px_user_id"].'">Show all drawings instead.</a></div></div>';
} else if ($pagenum == 1){
	echo '<div class="note"><div><strong>Welcome to 46px!</strong> These are pixel art drawings that others have created. Start your own tiny drawing, or tap one of the drawings below to draw your own version!</div></div>';
}

echo "<ul id='threads'>\n";

$result = $db->query($thread_query);
if ($result) {
    for ($i=0; $i < $result->num_rows; $i++) {
		$thread = $result->fetch_assoc();
		$post_result = $db->query("SELECT *, users.id as user_id FROM post INNER JOIN users ON post.user_id = users.id WHERE thread_id= ". $thread['id'] ." ORDER BY timestamp LIMIT 1");
		$post = $post_result->fetch_assoc();
		
		?>
		
		<li class='post'>
			<a href="thread.php?thread=<?=$thread['id'] . "&46px_user_id=" . $_GET['46px_user_id']?>">			
				<canvas id='canvas<?=$i ?>'></canvas>
			</a>
          
           <script>
           var i = new Image();
           i.canvas = "canvas<?= $i ?>";
           i.onload = replaceInto;
           i.src = "<?= str_replace('http://www.46px.com', '', $post['image_url']) ?>";
           </script>

		<div class="caption">
			<img src="http://graph.facebook.com/<?=$post["user_id"]?>/picture">
			<div id="postheader">
				<b><?=$post["first_name"]. " ". $post["last_name"] ?></b><br>
				<?=stripcslashes($post['caption']) ?><br>
				<span id="timestamp"><?= date('D, M jS \a\t g:iA', strtotime($post['timestamp'])) ?></span><br>
			</div>
			<div style="Clear:both;"></div>
		</div>
		
        </li>
        <?
        $curthread = $i + 1;
        
        if ($curthread % 3 == 0)
        	echo '<div style="Clear:both;"></div>';
    }
    $result->close();

} else {
	echo "No results to display";
}

echo "</ul>\n";
?>
<div id="page_controls">
<div style="float:left;">
<?
if ($pagenum > 1){
	echo " <a class='button' style='width=50' href='{$currentpage}&pagenum=1'> < First</a> ";
	echo "      ";
	$previous = $pagenum-1;
	echo " <a class='button' style='width=50' href='{$currentpage}&pagenum=$previous'> < Previous</a> ";
 } 
?>
</div>
<div style="float:right;">
<?
 //This does the same as above, only checking if we are on the last page, 
 //and then generating the Next and Last links
 if ($pagenum != $last_page_num){
	$next = $pagenum+1;
	echo " <a class='button' style='width=50' href='{$currentpage}&pagenum=$next'>Next ></a> ";
	echo "      ";
	echo " <a class='button' style='width=50' href='{$currentpage}&pagenum=$last_page_num'>Last ></a> ";
 } 

$db->close();
?>
</div>
</div>
<div style="clear:both;"></div>
</div>
</body>
</html>
