(function() {

  jQuery.extend({
    rounding : function(num, len){
      return Number(num).toFixed(len) - 0;
    }
  });

})(jQuery);
