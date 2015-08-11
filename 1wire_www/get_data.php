<?php

function get_data($date_start, $date_end) {
$dbconn = pg_connect("host=localhost port=5432 dbname=nolstedt user=nolstedt password=nolstedt connect_timeout=5");

$tempsql = "select sensor,value,time_utc from values where sensor=$1 and time_utc >= $2 and time_utc <= $3";
$tempsql = pg_prepare($dbconn, "my_value_query", $tempsql);
$cvalue = "select count(*) from values where sensor=$1 and time_utc >= $2 and time_utc <= $3";
$cvalue = pg_prepare($dbconn, "my_cvalue_query", $cvalue);



$sql = "select sensor, name from sensors where sensor_type = $1";
$sresult = pg_prepare($dbconn, "my_sensor_query", $sql);

$outout = array();
$sensorsql = "select distinct sensor_type from sensors";
$sensorres = pg_query($dbconn, $sensorsql);
while ($typerow = pg_fetch_row($sensorres)) {
	$sensortype = $typerow[0];
	
	$output[$sensortype] = array();
	$sresult = pg_execute($dbconn, "my_sensor_query", array($sensortype));
	while ($row = pg_fetch_row($sresult)) {
		$sensor = $row[0];
		$name = $row[1];
		$sensordata = array();
		$sensordata["sensor"] = $sensor;
		$sensordata["name"] = $name;
		$sensordata["data"] = array();	

		$ggg = pg_execute($dbconn, "my_cvalue_query", array($sensor,$date_start,$date_end));
		$gggrow = pg_fetch_row($ggg);
		$cc = $gggrow[0];
		$cc = round($cc / 288);
		$idx = 0;

		$tr = pg_execute($dbconn, "my_value_query", array($sensor,$date_start,$date_end));
		while ($trow = pg_fetch_row($tr)) {
			$value = $trow[1];
  			$time_utc = $trow[2] . " +00";
  			$date = new DateTime( $time_utc );
  			$date->setTimezone(new DateTimeZone('Europe/Stockholm'));
  			$time_local = $date->format('Y-m-d H:i:s');
  			$a = (int)$date->format('Y');
  			$b = (int)$date->format('m') - 1;
  			$c = (int)$date->format('d');
  			$d = (int)$date->format('H');
  			$e = (int)$date->format('i');
  			$f = (int)$date->format('s');

  			$data = array();
  			$data["a"] = $a;
  			$data["b"] = $b;
  			$data["c"] = $c;
  			$data["d"] = $d;
  			$data["e"] = $e;
  			$data["f"] = $f;
			if ($sensortype === "humidity") { 
  				$data["value"] = round(((float)$value), 0);
  			} else {
  				$data["value"] = round(((float)$value), 1);
			}
			if ($idx == 0) {
				array_push($sensordata["data"], $data);
			}
			$idx += 1;
			if ($idx >= $cc) {
				$idx = 0;
			}
		}
		array_push($output[$sensortype], $sensordata);
	}
}

pg_close($dbconn);
return json_encode($output);
}

if ( $_GET["date_start"] ) {
        $d = $_GET["date_start"];
        $sy = substr($d, 0, 4);
        $sm = substr($d, 4 ,2);
        $sd = substr($d, 6, 2);
        $date_start = gmdate("Y-m-d H:i:s", mktime(0, 0, 0, $sm, $sd, $sy));
} else {
        $date_start = gmdate("Y-m-d H:i:s", mktime(0, 0, 0, date("n"), date("j"), date("Y")));
}

if ( $_GET["date_end"] ) {
        $d = $_GET["date_end"];
        $sy = substr($d, 0, 4);
        $sm = substr($d, 4 ,2);
        $sd = substr($d, 6, 2);
        $date_end = gmdate("Y-m-d H:i:s", mktime(0, 0, 0, $sm, $sd, $sy));
} else {
	$date_end = gmdate("Y-m-d H:i:s", mktime(23, 59, 59, date("n"), date("j"), date("Y")));
}

$out = get_data($date_start, $date_end);
echo $out;

?>
