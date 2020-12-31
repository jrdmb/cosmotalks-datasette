<?php

// Examples:
/*
$str = "[Eiichiro Komatsu and Yuto Minami - A tantalising hint of parity violation in the cosmic microwave background](https://www.youtube.com/watch?v=9W9rDlEHg3c)";
if (stripos($str, "youtube") !== false && stripos($str, "?v=") !== false) {
  $ytid = substr($str,stripos($str,"?v=")+3,11);
  echo "\n$ytid\n";
}
$str = '"[Vivian Poulin - Theoretical explanations/solutions](https://youtu.be/g3964A8VZk0?t=5190)","ESO H0 2020 Conference",2020-06-25';
echo $str . "\n"; 
if (stripos($str, "youtu.be/") !== false) {
  echo substr($str, stripos($str, '.be/')+4, 11) . "\n"; 
}
*/
$db = 'cosmotalks.db';

try {
  $pdo = new PDO ("sqlite:" . $db);
  $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);  
} catch (PDOException $e) {
  echo "Failed to get DB handle: " . $e->getMessage() . "\n";
  exit;
}

// First, make sure the table is empty
$pdo->exec("DELETE FROM ytids");

// Now insert the youtube video ids that will be used to display a video's thumbnail image
$sql = "select rowid, talk from talks where talk like '%youtube.com%?v=%' or talk like '%youtu.be/%' order by rowid";
$query = $pdo->query($sql);
$pdo->beginTransaction();
$i = 0;
foreach($query as $row) {
  $talk = $row['talk'];
  $rid = $row['rowid'];
  if (stripos($talk, "youtube") !== false) {
    $ytid = substr($talk,stripos($talk,"?v=")+3,11);
  } else {
    $ytid = substr($talk, stripos($talk, '.be/')+4, 11); 
  } 
  //echo "Inserting => rowid: $rid | ytid:  $ytid\n";
  try {
    $sql = 'insert into ytids (rowid, ytid) values (?, ?)';
    $x = $pdo->prepare($sql);
    $x->bindParam(1, $rid, PDO::PARAM_INT);
    $x->bindParam(2, $ytid, PDO::PARAM_STR);
    $count = $x->execute() or die(print_r($pdo->errorInfo(), true));
  } catch (Exception $e) {
    $pdo->rollBack();
    echo "Transaction error: " . $e->getMessage();
  }
  $i++;
}
$pdo->commit();

echo "$i rows imported into the ytids table\n";

unset($pdo);
unset($query);
?>
