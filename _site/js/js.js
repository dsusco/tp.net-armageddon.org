$(function () {
  'use strict';

  var $toc = $('#table-of-contents > ol');

  $('h1[id], h2[id], h3[id]').each(function () {
    var $h = $(this),
      $a = $('<a>', { href: '#' + $h.prop('id') }).text($h.text());

    $a.addClass('_' + this.tagName.toLowerCase());

    if ($h.hasClass('no-count')) {
      $a.addClass('no-count');
    }

    if ($h.hasClass('sr-only')) {
      $a.addClass('sr-only');
    }

    $toc.append($('<li>').append($a));
  });

  $toc.prev('.fa').click(function () {
    var $fa = $(this);

    $fa.toggleClass('fa-minus-circle fa-plus-circle')
      .parent().toggleClass('expanded');
  });

  $('.table-army-list:not(:has(.table-army-list)) > tbody').each(function () {
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