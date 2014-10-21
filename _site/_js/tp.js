$(function () {
  'use strict';

  $('html').toggleClass('js no-js');

  if (typeof Prince !== 'undefined') {
    $('html').toggleClass('no-prince prince');
  }

  $('h1[id], h2[id], h3[id]').each(function () {
    var $h = $(this),
      $a = $('<a>', { href: '#' + $h.prop('id') }).append($h.text());

    $a.addClass(this.tagName.toLowerCase());

    if ($h.hasClass('no-count')) { $a.addClass('no-count'); }

    if ($h.hasClass('sr-only')) { $a.addClass('sr-only'); }

    $('#table-of-contents ol').append($('<li>').append($a));
  });

  $('.table-army-list:not(:has(.table-army-list)) > tbody').each(function () {
    var $tbody = $(this),
      cols = $tbody.siblings('colgroup').children('col').length,
      stripe = false;

    $('> tr', $tbody).each(function () {
      var $tr = $(this),
        cells = 0;

      $('> th, > td', $tr).each(function () {
        cells += +this.getAttribute('colspan') || 1;
      });

      if (cols === cells) { stripe = !stripe; }

      if (stripe) { $tr.addClass('stripe'); }
    });
  });
});