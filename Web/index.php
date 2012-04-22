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

$num_threads = 6; // The number of threads to be shown per page

$data = $db->query("SELECT * FROM thread") or die(mysql_error());
$num_rows = $data->num_rows;
$last_page_num = ceil($num_rows/$num_threads); // This is the number of the last page.

if ($pagenum < 1) $pagenum = 1;
if ($pagenum > $last_page_num) 	$pagenum = $last_page_num;
	
// Sets the range of the query
$max = 'LIMIT ' .($pagenum - 1)* $num_threads . ',' . $num_threads;

echo "<ul id='threads'>\n";
if ($result = $db->query("SELECT * FROM thread ORDER BY timestamp Desc " . $max)) {
    
    for ($i=0; $i < $result->num_rows; $i++) {
		$thread = $result->fetch_assoc();
		$post_result = $db->query("SELECT *, users.id as user_id FROM post INNER JOIN users ON post.user_id = users.id WHERE thread_id= ". $thread['id'] ." ORDER BY timestamp LIMIT 1");
		$post = $post_result->fetch_assoc();
		
		?>
		
		<li class='post'>
			<a href="thread.php?thread=<?=$thread['id'] . "&46px_user_id=" . $_GET['46px_user_id']?>">			
				<canvas style="width:230px; height:230px;" id='canvas<?=$i ?>'></canvas>
			</a>
          
           <script>
           var i = new Image();
           i.canvas = "canvas<?= $i ?>";
           i.onload = replaceInto;
           i.src = "<?= str_replace('http://www.46px.com', '', $post['image_url']) ?>";
           </script>

		<div class="caption" style="width:230px; background-color:rgba(255,255,255,0.5); border:0px; padding:5px; clear:left; margin-top:10px; word-wrap: break-word;">
			<img style="float:left; padding-right:5px;" src="http://graph.facebook.com/<?=$post["user_id"]?>/picture">
			<div style="float:right; width:170px;">
				<b><?=$post["first_name"]. " ". $post["last_name"] ?></b><br>
				<?=$post['caption']?><br>
				<span style="font-size:0.9em; color:gray;"><?= date('D, M jS \a\t g:iA', strtotime($post['timestamp'])) ?></span><br>
			</div>
			<div style="Clear:both;"></div>
		</div>
		
        </li>
        <?
        $curthread = $i + 1;
        
        if ($curthread % 2 == 0)
        	echo '<div style="Clear:both;"></div>';
    }
    $result->close();

} else {
	echo "Didn't access DB\n";
}

echo "</ul>\n";
?>
<div style="width: 100%; text-align:center;">
<?
if ($pagenum > 1){
	echo " <a class = 'button' style='width=50' href='{$_SERVER['PHP_SELF']}?pagenum=1'> < First</a> ";
	echo "      ";
	$previous = $pagenum-1;
	echo " <a class = 'button' style='width=50' href='{$_SERVER['PHP_SELF']}?pagenum=$previous'> < Previous</a> ";
 } 

 //This does the same as above, only checking if we are on the last page, 
 //and then generating the Next and Last links
 if ($pagenum != $last_page_num){
	$next = $pagenum+1;
	echo " <a class='button' style='width=50' href='{$_SERVER['PHP_SELF']}?pagenum=$next'>Next ></a> ";
	echo "      ";
	echo " <a class='button' style='width=50' href='{$_SERVER['PHP_SELF']}?pagenum=$last_page_num'>Last ></a> ";
 } 

$db->close();
?>
</div>
</div>
</body>
</html>