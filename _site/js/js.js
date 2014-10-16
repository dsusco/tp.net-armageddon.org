$(function () {
  'use strict';

  $('.table-army-list > tbody').each(function () {
    // get the number of columns in each table body...
    var $tbody = $(this),
      cols = $tbody.siblings('colgroup').children('col').length,
      stripe = false;

    // and for each row...
    $('> tr', $tbody).each(function () {
      var $tr = $(this),
        cells = 0;

      // count its cells
      $('> th, > td', $tr).each(function () {
        cells += +this.getAttribute('colspan') || 1;
      });

      // only flip the stripe when it's a complete row
      if (cols === cells) { stripe = !stripe; }

      if (stripe) { $tr.addClass('stripe'); }
    });
  });
});