var highchart = {
        chart: { type: 'spline' },
        title: { text: 'unset', },
        xAxis: {
                type: 'datetime',
                dateTimeLabelFormats: { month: '%e. %b', year: '%b' }
        },
        yAxis: { title: { text: 'unset' }, },
        plotOptions: {
            spline: {
                marker: { enable: false }
            }
        },
        tooltip: {
                formatter: function() { return '<b>' + this.series.name + '</b><br/>' + Highcharts.dateFormat('%H:%M:00', this.x) +': '+ this.y;
                }
       	},
};

$(function () {
    highchart.title.text = "temperatur";
    highchart.yAxis.title.text = 'Temp (°C)';
    $('#temperature_container').highcharts( highchart );

    highchart.yAxis.title.text = '%';
    highchart.title.text = "fukt";
    $('#humidity_container').highcharts( highchart );

var success = function(data) {
        $.each(Object.keys(data), function(ik,dk) {
                var chartid = "#" + dk + "_container";
                chart = $(chartid).highcharts();
                while(chart.series.length > 0) {
                        chart.series[0].remove(true);
                }

                $.each(data[dk], function(ii,dd) {
                        name = dd["name"];
                        var o = [];
                        $.each(dd["data"], function(i,d) {
                                v = [];
                                v.push(Date.UTC(d["a"], d["b"], d["c"], d["d"], d["e"], d["f"]));
                                v.push(d["value"]);
                                o.push(v);
                        });
                        //chart.addSeries( {name: name, data: o, color: '#445566'}, true);
                        chart.addSeries( {name: name, data: o}, true);
                });
        });
	enableButtons();
};

var setDataDate = function(d) {
        a = new Date();
        a.setDate(d.getDate()-1);
        $("#prev").data("date", a);
	
	b = new Date();
	b.setDate(d.getDate()+1);
	$("#next").data("date", b);
};

var updateChartByDate = function(n,m) {
	setDataDate(n);
        obj = {date_start: "" + n.getFullYear() + digits("" + (n.getMonth()+1)) + digits(""+ n.getDate()),
	date_end: "" + m.getFullYear() + "" + (m.getMonth()+1) + digits(""+ m.getDate()) };

        $.getJSON ( "get_data.php" , obj, success);
};

var disableButtons = function() {
	$(".btn").attr("disabled","disabled");
};
var enableButtons = function() {
	$(".btn").removeAttr("disabled");
};
var digits = function(d) {
if (d.length == 1) {
return "0"+d;
} else {
return d;
}
};

d = new Date();
obj = {date_start: "" + d.getFullYear() + digits("" + (d.getMonth()+1)) + digits(""+ d.getDate()) };
$("#prev").data("date", d);
$("#next").data("date", d);
setDataDate(d);

$.getJSON ( "get_data.php" , obj, success);


$("#prev").click( function() {
	disableButtons();
        n = $("#prev").data("date");
	a = new Date();
        a.setDate(n.getDate()+1);
	updateChartByDate(n,a);
});
$("#next").click( function() {
	disableButtons();
        n = $("#next").data("date");
	a = new Date();
        a.setDate(n.getDate()+1);
	updateChartByDate(n,a);
});
$("#last7days").click( function() {
	disableButtons();
	n = new Date();
	d = new Date();
	d.setDate(n.getDate()-6);
	updateChartByDate(d,n);
});
$("#currentmonth").click( function() {
	disableButtons();
	var date = new Date();
	var firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
        updateChartByDate(firstDay,date);
});

});
