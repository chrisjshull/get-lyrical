<?php
////
// Author: Sean Colombo
// Date: 20060715
//
// A test client that can talk to the LyricWiki SOAP server.
////

// Pull in the NuSOAP code
require_once('nusoaplib/nusoap.php');
// Create the client instance
$client = new nusoap_client('http://lyricwiki.org/server.php?wsdl', true);
// Check for an error
$err = $client->getError();
if ($err) {
	// Display the error
	echo '<h2>Constructor error</h2><pre>' . $err . '</pre>';
	// At this point, you know the call that follows will fail
}
//echo "connected";
//die();
// Create the proxy
$proxy = $client->getProxy();

$method = "checkSongExists";
//$method = "searchArtists";
//$method = "searchAlbums";
//$method = "searchSongs";
//$method = "getSong";
//$method = "getArtist";
//$method = "getAlbum";
//$method = "postArtist";
//$method = "postAlbum";
//$method = "postSong";
if($method == "checkSongExists"){
	$artist = "Tool";
	$song = "Lateralus";
	$result = $proxy->checkSongExists($artist, $song);
} else if($method == "searchArtists"){
	$searchString = "Scooter";
	$result = $proxy->searchArtists($searchString);
} else if($method == "searchAlbums"){
	$artist = "Tool";
	$album = "Lateralus";
	$year = 2001;
	$result = $proxy->searchAlbums($artist, $album, $year);
} else if($method == "searchSongs"){
	$artist = "Scooter";
	$song = "Posse, I Need You";
	$result = $proxy->searchSongs($artist, $song);
} else if($method == "getSong"){
	$artist = "Scooter";
	$song = "Posse, I Need You";
	$result = $proxy->getSong($artist, $song);
} else if($method == "getArtist"){
	$artist = "Pink Floyd";
	$result = $proxy->getArtist($artist);
} else if($method == "getAlbum"){
	$artist = "Pink Floyd";
	$album = "Dark Side Of The Moon";
	$year = 1973;
	$result = $proxy->getAlbum($artist, $album, $year);
} else if($method == "postArtist"){
	$albums = array();
	$asin = 'B0009X777W';
	$artist = 'Staind';
	$songs = array('Price To Play', 'How About You', 'So Far Away');
	$albums[] = array('album' => '14 Shades Of Grey', 'year' => 2003, 'amazonLink' => $asin, 'songs' => $songs);
	$songs = array('Run Away', 'Right Here', 'Paper Jesus', 'Schizophrenic Conversations');
	$albums[] = array('album' => 'Chapter V', 'year' => 2005, 'amazonLink' => $asin, 'songs' => $songs);
	$overwriteIfExists = false;
	$result = $proxy->postArtist($overwriteIfExists, $artist, $albums);
} else if($method == "postAlbum"){
	$artist = 'Staind';
	$album = 'Chapter V';
	$year = 2005;
	$asin = 'B0009X777W';
	$overwriteIfExists = false;
	$songs = array('Run Away', 'Right Here', 'Paper Jesus', 'Schizophrenic Conversations');
	$result = $proxy->postAlbum($overwriteIfExists, $artist, $album, $year, $asin, $songs);
} else if($method == "postSong"){
	$artist = 'The Clarks';
	$song = 'Hey You';
	$lyrics = "If you're gonna jump, hey you hang on
If you feel like giving up, hey you hang on
Won't forget today sun is bright, sky is blue yeah
The pain will go away in another year or two

If you got a phone, hey you call home
If you got a voice, hey you rejoice

Won't forget today sun is bright, sky is blue yeah
Won't forget to pray day is night, world is new yeah
Pain will go away in another year or two
In a hundred years or two

If you're gonna fly, hey you don't cry
You gotta live to die, hey you goodbye

Won't forget today sun is bright, sky in blue yeah
Won't forget to pray day is night world is new yeah
Pain will go away in another year or two
In a hundred years or two

...In a thousand years or two";
	$onAlbums = array();
	// If the artist is left blank it defaults to the artist of the song.  Left out here to conserve space.
	$onAlbums[] = array('artist'=>'', 'album'=>'Another Happy Ending', 'year' => 2002);
	$onAlbums[] = array('artist'=>'', 'album'=>'Between Now And Then - Retrospective', 'year' => 2005);
	$onAlbums[] = array('artist'=>'', 'album'=>'Still Live', 'year' => 2006);
	$overwriteIfExists = false;
	$result = $proxy->postSong($overwriteIfExists, $artist, $song, $lyrics, $onAlbums);
} else {
	print "Method not recognized: $method<br/>\n";
}

// Check for a fault
if ($proxy->fault) {
	echo '<h2>Fault</h2><pre>';
	print_r($result);
	echo '</pre>';
} else {
	// Check for errors
	$err = $proxy->getError();
	if ($err) {
		// Display the error
		echo '<h2>Error</h2><pre>' . $err . '</pre>';
	} else {
		// Display the result
		echo '<h2>Result</h2><pre>';
		print_r($result);
	echo '</pre>';
	}
}
// Display the request and response
echo '<h2>Request</h2>';
echo '<pre>' . htmlspecialchars($proxy->request, ENT_QUOTES) . '</pre>';
echo '<h2>Response</h2>';
echo '<pre>' . htmlspecialchars($proxy->response, ENT_QUOTES) . '</pre>';
// Display the debug messages
echo '<h2>Debug</h2>';
echo '<pre>' . htmlspecialchars($proxy->debug_str, ENT_QUOTES) . '</pre>';
?>