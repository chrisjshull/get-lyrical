<?php //1.3.1

ini_set('user_agent', 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-us) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10');	
	
error_reporting(E_ERROR); 
//error_reporting(E_ALL);
//ini_set("display_errors", 0); 

$artist1 = (trim($argv[1]));
$song1 = (trim($argv[2]));

$dohead = ($argv[3] == 1);  
$dofoot = ($argv[4] == 1);

//$song = decodeURIComponent(urlencode(($song)));
//$artist = decodeURIComponent(urlencode(($artist)));

//$artist1="周杰伦"; $song1 = "简单爱";


//print_r($artist);

/* TEST CASES
	\ "Nine Inch Nails" "Right Where It Belongs"
	failed requests for Cassie:Me when the real song name is Cassie:Me & U
	Michael Jackson
	feat / feaating / ft. / , / 'and' in either
	( and [ in either
	Message In A Bottle The Police "{{SOTD|date=September 10,2007}}"
	Truly, Madly, Deeply : Savage Garden
	http://lyricwiki.org/Fame_Musical:I_Sing_The_Body_Electric
	
	//http://lyricwiki.org/LyricWiki_talk:SOAP
*/

//touch("/tmp/gl-go-type");
$tc = exec('defaults read com.shullian.getlyrical gl-go-type 2>/dev/null');//file_get_contents("/tmp/gl-go-type");
//echo $tc;

$CODE="en";
if ($tc=="") {
	$en = (int)exec("ping -n -c2 -t2 lyrics.wikia.com | grep time= | sed 's/.*time=//'");
	$zh = (int)exec("ping -n -c2 -t2 www.qianqian.com | grep time= | sed 's/.*time=//'");
	//echo $en."\n";
	//echo $zh;
	if ($zh<$en && $zh != 0) {
		$CODE = "zh";
	}
	else {
		$CODE = "en";
	}
	exec('defaults write com.shullian.getlyrical gl-go-type '.$CODE);
}
else {
	$CODE = trim($tc);
}
//die($CODE);

function zh_parsepage($url, $song, $artist, $dohead, $dofoot) {	

	//http://forums.digitalpoint.com/showthread.php?t=1463876
	$opts = array(
	  'http'=>array(
		'method'=>"GET",
		'header'=>"Referer: http://www.qianqian.com\r\n"
	  )
	);
	$GLOBALS['context'] = stream_context_create($opts);
	
	//echo "parsepage:".$url."\n";
	//echo "fetching from: ".$url."\n";
	$page = file_get_contents("http://www.qianqian.com/lrcresult_frame.php?qfield=3&qword=".$url,false,$GLOBALS['context']);
	//echo $page."\n\n";
	$pattern = '#(/downfromlrc\.php.*)">#';
	preg_match($pattern, $page, $matches);
	//print_r($matches);
	if (count($matches)<2) return;
	
	$page = file_get_contents("http://www.qianqian.com".$matches[1],false,$GLOBALS['context']);
	
	$page = preg_replace("/\[..:\].*\n/","",$page);
	
	//echo $page;
	
	$page = trim(preg_replace("/\[.*\]/","",$page));
	
	if ($page != "") {
		if ($dohead) echo $song."\n".$artist."\n"."\n";
		echo ($page);
		if ($dofoot) echo "\n"."\n"."[ Get Lyrical : "."http://www.qianqian.com/lrcresult.php?qfield=3&pageflag=1&qword=".$url." ]";
		die();
	}
	
	//die();
}

if ($CODE == "zh") {
	$song = iconv('UTF-8','GBK',$song1);
	$song = rawurlencode($song);
	$artist=iconv('UTF-8','GBK',$artist1);
	$artist = rawurlencode($artist);
	$url = "".$song."%20".$artist;
	//echo $url."\n\n";
	//die();
	
	zh_parsepage($url, $song1, $artist1, $dohead, $dofoot);
	//for: 周
	//correct: %D6%DC
	//i get: %E5%91%A8
	
	//die();
}


$song = rawurlencode($song1);
$artist = rawurlencode($artist1);
$url = "http://lyrics.wikia.com/api.php?action=lyrics&artist=".$artist."&song=".$song."&fmt=xml&func=getSong";
//echo "$url\n";
$cont = file_get_contents($url);
if (!!$cont && $cont != "") {
	$cont = str_replace("\n",'',$cont);
	$cont = preg_replace('/<lyrics>.*<\/lyrics>/','',$cont);
	//echo $cont;
	$result = (simplexml_load_string($cont));
	//print_r($result);die();
	// Check for a fault
}

function parsepage($url, $song, $artist, $dohead, $dofoot) {	
	
	//echo "parsepage:".$url."\n";
	
	if ($GLOBALS['checkheads']) {
		try {
			$headers = get_headers($url,1);
			//echo $headers[1];
			if (preg_match('/404/',$headers[1]))
				return;
			//echo $headers[1];
		} catch (Exception $e) {
			//nada
		}
	}

	
	//echo "fetching from: ".$url."\n";
	$page = file_get_contents($url);
	//echo $page."\n\n";
	
	if (preg_match('/Category:Unlicensed Lyrics/',$page)) {
		return;
	}
	
	$page = preg_replace("/<div class='rtMatcher'.+?<\/div>/", "", $page);
	$PS = preg_split("/<div class='lyricbox'[ ]*>/",$page);
	for ($i=1;$i<count($PS);$i++) {
		$page1 = $PS[$i];
		
		//echo $page1;
		$pages = preg_split("/<\/div>/",$page1);
		
		$page0 = $pages[0];
		$page0 = (preg_replace('/<br[ ]*\/*>/',"\n",$page0));
		
		$page0 = strip_tags($page0);
		$page0 = html_entity_decode($page0, ENT_QUOTES, "UTF-8");
		//$page0 = preg_replace('/&nbsp;/'," ",$page0); // this is here just to fix this: http://lyrics.wikia.com/Alain_Souchon:Poulailler's_Song
		$page0 = html_entity_decode($page0, ENT_QUOTES, "UTF-8"); // YES - RUN IT TWICE!
		$page0 = trim($page0);
		
		//$page0 = utf8_encode($page0);
		
		//$page0 = trim(utf8_encode());
		//$page0 = preg_replace('/&nbsp;/'," ",$page0);
		//print_r($page0);
		//die();
		if ($page0 != "") {
			if ($dohead) echo $song."\n".$artist."\n"."\n";
			echo ($page0);
			if ($dofoot) echo "\n"."\n"."[ Get Lyrical : ".$url." ]\n";
			die();
		}
	}
}

$GLOBALS['checkheads'] = false;
if (!!$result && $result->url && $result->url != "http://lyrics.wikia.com" && strpos($result->url,"action=edit") === false) {
	//echo "t0".$result->url."\n";
	parsepage($result->url, $result->song, $result->artist, $dohead, $dofoot);
	
	$GLOBALS['checkheads'] = true;
	
	if (preg_match('#http://lyrics.wikia.com/lyrics/#', $result->url))
		$url = str_replace('http://lyrics.wikia.com/lyrics/','http://lyrics.wikia.com/',$result->url);
	else
		$url = str_replace('http://lyrics.wikia.com/','http://lyrics.wikia.com/lyrics/',$result->url);
	
	parsepage($url, $result->song, $result->artist, $dohead, $dofoot);
	
	$url = str_replace('http://lyrics.wikia.com/','http://lyrics.wikia.com/lyrics/',$result->url);
	$url = str_replace('%2F','/',$url);
	parsepage($url, $result->song, $result->artist, $dohead, $dofoot);
	
	$url = str_replace('http://lyrics.wikia.com/lyrics/','http://lyrics.wikia.com/',$result->url);
	$url = str_replace('%2F','/',$url);
	parsepage($url, $result->song, $result->artist, $dohead, $dofoot);
}
else {
	$GLOBALS['checkheads'] = true;
	//echo "t1\n";
	$songT = str_replace(' ','_',ucwords($song1));
	$artistT = str_replace(' ','_',ucwords($artist1));
	
	$song = rawurlencode($songT);
	$artist = rawurlencode($artistT);
	
	/*parsepage("http://lyrics.wikia.com/lyrics/".$artist.":".$song, $result->song, $result->artist, $dohead, $dofoot);
	parsepage("http://lyrics.wikia.com/lyrics/Gracenote:".$artist.":".$song, $result->song, $result->artist, $dohead, $dofoot);
	*/
	parsepage("http://lyrics.wikia.com/lyrics/Gracenote:".$artist.":".$song, $song1, $artist1, $dohead, $dofoot);
	parsepage("http://lyrics.wikia.com/lyrics/".$artist.":".$song, $song1, $artist1, $dohead, $dofoot);

}
die();

?>
