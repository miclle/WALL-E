(function() {

  jQuery.extend({
    rounding : function(num, length){
      // var pv = Math.pow(10, length);
      // return Math.round(num * pv) / pv;
      return Number(num).toFixed(length) - 0;
    }
  });

})(jQuery);
