<?php

$db = new mysqli('external-db.s75591.gridserver.com', 'db75591_46px','hacknashville', 'db75591_46px');
if ($db->connect_error) {
	die('Connect Error (' . $db->connect_errno . ') ' . $db->connect_error);
}

if (mysqli_connect_error()) {
	die('Connect Error (' . mysqli_connect_errno() . ') ' . mysqli_connect_error());
}

$threadid = "where thread_id=".$_GET['thread'];
$result = $db->query("SELECT *, post.id AS id, users.id AS user_id FROM post INNER JOIN users ON users.id = post.user_id $threadid ORDER BY timestamp");

if (($result === false) || ($result->num_rows == 0)) {
	echo "Uhoh... the thread doesn't exist!";
	die();
}
?>

<!DOCTYPE html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<link rel='stylesheet' type='text/css' href='css/mainstyle.css'/>
	<link rel='stylesheet' type='text/css' href='css/threadstyle.css'/>
</head>
<body>

<div id='wrapper' style="width:770px; margin:auto;">

	<script language="javascript">
		var zoom = 11.2;
	</script>
	<script src="js/images.js" language="javascript"></script>

	<div style="float:right;">
		<a class="button" href="#replies"><img src="/images/icon_comments.png"><span style="padding-left:10px; padding-right:4px; font-size:30px; position:relative; top:-10px;">
			<?= $result->num_rows - 1 ?>
		</span></a>
	</div>
	
	<ul id='thread'>

<?php
	for ($i = 0; $i < $result->num_rows; $i++)  {
		$row = $result->fetch_assoc();
		
		// determine if this post was liked by the current user
		$liked = false;
		if (isset($_GET['46px_user_id']) && ($_GET['46px_user_id'] != "")) {
			$liked = $db->query("SELECT * FROM like_list WHERE post_id = '".$row['id']."' AND user_id = '".$_GET['46px_user_id']."' LIMIT 1");
			$liked = ($liked->num_rows > 0);
		}
		
		$like_count = $db->query("SELECT * FROM like_list WHERE post_id = '".$row['id']."'")->num_rows;
		
		?>
		<li style="border-bottom:6px dashed rgba(0,0,0,0.2); padding-bottom:30px; margin-bottom:30px;">
			<div style="background:url('/images/post_frame.png') top left no-repeat; width:588px; height:530px;">
			   <canvas style="padding-left:18px; padding-top:6px;" id='canvas<?= $i ?>'></canvas>
			   <script>
			   var i = new Image();
			   i.canvas = "canvas<?= $i ?>";
			   i.onload = replaceInto;
			   i.src = "<?= str_replace('http://www.46px.com', '', $row['image_url']) ?>";
			   </script>
			</div>
			
			<div style="background:url('/images/caption_frame.png') top left no-repeat; width:588px; height: 77px; margin-top:15px;">
			
				<div style="float:left; z-index:3; position:relative; left: 44px; top:6px;">
					<img src="http://graph.facebook.com/<?=$row["user_id"]?>/picture" style="width:65px; height:65px;" />
				</div>
				
				<div style="float:left; z-index:2; position:relative; left: 65px; top:10px; text-align:left; width:290px; word-wrap: break-word;">
					<b><?=$row["first_name"]. " ". $row["last_name"] ?></b> <span style="font-size:0.9em; color:gray;"><?= date('D, M jS, g:iA', strtotime($row['timestamp'])) ?></span>
					<br><?=stripcslashes($row['caption'])?>
				</div>
				
				
				<div style="float:left; z-index:4; position:relative; left: 93px; top:17px;">
					<a href="like.php?post_id=<?echo $row['id'] . "&thread_id=" . $row['thread_id']. "&46px_user_id=" . $_GET['46px_user_id']?>">
					<? if ($liked == true) { ?><img src="/images/icon_like_down.png"><? } else { ?><img src="/images/icon_like.png"><?}?></a>
					<span style="text-align:center; width:40px; padding-right:4px; font-size:30px; font-weight:bold; position:relative; top:-5px;">
						<?=$like_count ?>
					</span>
				</div>
				<div style="float:left; z-index:4; position:relative; left: 112px; top:17px;">
					<a href="fortysix://edit---<?=$row['image_url']?>---<?=$row['thread_id']?>"><img src="/images/icon_draw.png"></a>
				</div>
			</div>
		</li>
	<? 
	if ($i == 0) {
		echo "<div id='replies'></div>";
	}
}
?>
</ul>

<?
$db->close();
?>

	<div style="margin:auto; width: 300px; padding-bottom:50px;">
		<a class="button" style="width: 300px;" href='fortysix://edit---<?=$row['thread_id']?>'>Create Blank Reply</a>
	</div>
    
</div>
</body>
</html>