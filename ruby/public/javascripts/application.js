$(function (){

  // Radialize the colors
  Highcharts.getOptions().colors = Highcharts.map(Highcharts.getOptions().colors, function(color) {
    return { radialGradient: { cx: 0.5, cy: 0.3, r: 0.7 }, stops: [ [0, color], [1, Highcharts.Color(color).brighten(-0.3).get('rgb')]] };
  });

  // Build the chart
  var chart = new Highcharts.Chart({
    credits:  { enabled: false  },
    chart:    { renderTo: 'memory-pie' },
    title:    { text: 'System Memory' },
    tooltip:  { pointFormat: '<b>{point.y}MB</b>' },
    plotOptions: {
      pie: {
        allowPointSelect: true,
        dataLabels: {
          color: '#000000',
          formatter: function() {
            return '<b>'+ this.key +'</b>: '+ this.y +' MB';
          }
        }
      }
    },
    series: [{ type: 'pie' }]
  });

  var getSystemInfo = function(){

    $.getJSON('/system', function(info){
      var stat = info['stat'];

      var user = stat['user'], nice = stat['nice'], system = stat['system'], idle = stat['idle'], iowait = stat['iowait'], irq = stat['irq'], softirq = stat['softirq'];

      var cpuUsages = $.cpuStat(user, nice, system, idle, iowait, irq, softirq);

      console.log(cpuUsages);

      var memory = info['memory'];
      chart.series[0].setData([
        ['buffers', $.rounding(memory['buffers']/1024, 2)],
        ['cached',  $.rounding(memory['cached']/1024, 2)],
        ['free',    $.rounding(memory['free']/1024, 2)],
        ['used',    $.rounding((memory['total'] - memory['free'] - memory['buffers'] - memory['cached'])/1024, 2)]
      ]);
      // setTimeout(getSystemInfo, 1000 * 5);
    });
  }

  getSystemInfo();

});