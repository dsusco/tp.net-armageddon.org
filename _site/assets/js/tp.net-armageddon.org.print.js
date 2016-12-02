---
include:
  - bower_components/jquery-2.2.4/dist/jquery.js
---
$(function () {
  'use strict';

  $('html')
    .first().toggleClass('js no-js');

  $('#nav').detach().insertAfter($('#copyright'));

  // change anchor text to heading number if it exists
  $('.default-layout #main a[href]').each(function () {
    try {
      var number = $($(this).attr('href').match(/(#.+)$/).pop()).data('number');

      if (number) {
        this.innerHTML = number;
      }
    } catch (e) {}
  });

  // zebra stripe all army list table bodies that don't contain another army list table
  $('.table-army-list:not(:has(.table-army-list)) > tbody').each(function () {
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

      if (cols === cells) { stripe = !stripe; }

      if (stripe) { $tr.addClass('stripe'); }
    });
  });
});
