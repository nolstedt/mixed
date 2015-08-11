<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
</head>
<script src="//code.jquery.com/jquery-2.1.1.min.js"></script>
<script src="http://code.highcharts.com/highcharts.js"></script>
<script src="http://code.highcharts.com/modules/exporting.js"></script>
<script src="thejs.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
<body>

<div class="container">
	<div class="row">
		<div id="temperature_container" style="min-width: 310px; height: 300px; margin: 0 auto"></div>
		<div id="humidity_container" style="min-width: 310px; height: 300px; margin: 0 auto"></div>
	</div>	

	<div class="row">
	<div class="col-md-12 text-center">
		<a class="btn btn-default" href="#" id="prev">Previous day</a>
		<a class="btn btn-default" href="#" id="next">Next day</a>
		<a class="btn btn-default" href="#" id="last7days">Last 7 days</a>
		<a class="btn btn-default" href="#" id="currentmonth">Current month</a>
	</div>
	</div>
</div>
<br>
</body>
</html>
