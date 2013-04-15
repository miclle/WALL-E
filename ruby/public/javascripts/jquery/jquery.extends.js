(function() {

  jQuery.extend({
    rounding : function(num, len){
      return Number(num).toFixed(len) - 0;
    },
    cpuStat : function(user, nice, system, idle, iowait, irq, softirq){

      var total = user + nice + system + idle + iowait + irq + softirq;
      // $.data(window, 'foo', 1314324132413241324132413241324);

      // window.user     = user;
      // window.nice     = nice;
      // window.system   = system;
      // window.idle     = idle;
      // window.iowait   = iowait;
      // window.irq      = irq;
      // window.softirq  = softirq;

      // console.log(user/total, system/total, idle, 1 - idle/total);
      // Number(5.56789).toFixed(2) - 0;
      return {user: (user/total*100).toFixed(2) - 0, system: (system/total*100).toFixed(2) - 0, idle: (idle/total*100).toFixed(2) - 0, usage: ((1 - idle/total)*100).toFixed(2) - 0};

    }
  });

})(jQuery);
