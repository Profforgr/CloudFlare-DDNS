<?php
	if(isset($_POST["option"])) {
		
		$option = $_POST["option"];
		
		switch ($option) {
			case 0:
				echo $_SERVER['REMOTE_ADDR'];
				break;
				
			case 1:
				$file = file_get_contents($_FILES["file"]["tmp_name"]);
				$needle = $_POST["host"];
				$haystack = json_decode($file, true);
				$count = $haystack['response']['recs']['count'];
				$i = 0;
				while($i < $count) {
					if( $needle == $haystack['response']['recs']['objs'][$i]['display_name'] ) {
						$rec_id = $haystack['response']['recs']['objs'][$i]['rec_id'];
						break;
					}
					else {
						$i++;
					}
				}
				echo $rec_id;
				break;
				
			default:
				echo "401 Bad Request \n";
		}
	}
	
	else {
		echo "401 Bad Request \n";
	}
?>
