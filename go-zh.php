<?php //0.1

//defaults read -g AppleLanguages
//defaults read -g AppleLanguages | head -n 2 | tail -n 1 | grep "zh"


//echo $CODE;

die();

ini_set('user_agent', 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-us) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10');	


error_reporting(E_ERROR); 
//error_reporting(E_ALL);
//ini_set("display_errors", 0); 

$artist1 = (trim($argv[1]));
$song1 = (trim($argv[2]));

$dohead = ($argv[3] == 1);  
$dofoot = ($argv[4] == 1);





?>
