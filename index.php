<?php
	
	if(isset($_POST["option"])) { // check if the "option" parameter is POSTed to the server
		
		$option = $_POST["option"]; //if it is, put the contents in $option
		
		switch ($option) { // switch/case setup to determine what option was selected
			
			case 0: // if option 0 was selected, echo back the user's IP and quit
				echo $_SERVER['REMOTE_ADDR'];
				break;
			
			case 1: // if option 1 was selected...
				$file = file_get_contents($_FILES["file"]["tmp_name"]); // put the contents of the uploaded file in the $file variable
				if(isset($_POST["host"]) { // if "host" was posted, put it in the variable $needle
					$needle = $_POST["host"];
				}
				else { //if it wasn't set the response code to 400 and echo it back to the client
					http_response_code(400);
					echo "400 Bad Request, missing host parameter in POST";
				}
				$haystack = json_decode($file, true); // decode the JSON into an array called $haystack
				$count = $haystack['response']['recs']['count']; // get the number of records from the haystack
				$i = 0; // start the counter $i at 0
				while($i < $count) { // while the counter is less than the number of results
					if( $needle == $haystack['response']['recs']['objs'][$i]['display_name'] ) { // check the haystack for the needle 'display name'
						$rec_id = $haystack['response']['recs']['objs'][$i]['rec_id']; // if found, get the 'rec_id', call it $rec_id and quit the loop
						break;
					}
					else { // if not found, increment $i
						$i++;
					}
				}
				echo $rec_id; // send back the $rec_id and quit
				break;

			default: // if the option selected wasn't listed above, set the response code to 400 and echo it back to the client
				http_response_code(400);
				echo "400 Bad Request, invalid option set";
		}
	}

	else { // if the option wasn't POSTed, set the response code to 400 and echo it back to the client
		http_response_code(400);
		echo "400 Bad Request, no option set";
	}
?>
