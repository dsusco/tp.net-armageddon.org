jQuery.fn.extend({
  zebraStripe: function () {
    return this.each(function () {
      var
        $tbody = $(this),
        cols = $tbody.siblings('colgroup').children('col').length,
        stripe = false;

      $('> tr', $tbody).each(function () {
        var
          $tr = $(this),
          cells = 0;

        $('> th, > td', $tr).each(function () {
          cells += +this.getAttribute('colspan') || 1;
        });

        if (cols === cells) {
          stripe = !stripe;
          $tr.addClass('bordered');
        }

        if (stripe) {
          $tr.addClass('striped');
        }
      });
    });
  }
});
