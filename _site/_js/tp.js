$(function () {
  'use strict';

  $('html').toggleClass('js no-js');

  if (typeof Prince !== 'undefined') {
    $('html').toggleClass('no-prince prince');
  }

  // build the table of contents
  $('h1[id], h2[id], h3[id]').each(function () {
    var $h = $(this),
      $a = $('<a>', { href: '#' + $h.prop('id') }).append($h.text());

    $a.addClass(this.tagName.toLowerCase());

    if ($h.hasClass('no-count')) { $a.addClass('no-count'); }

    if ($h.hasClass('sr-only')) { $a.addClass('sr-only'); }

    $('#table-of-contents ol').append($('<li>').append($a));
  });

  // for each internal link that's not in the table of contents...
  $('main:not(.no-outline) section:not(#table-of-contents) a[href^="#"]').each(function () {
    var $a = $(this);

    // replace its text with the linked to heading's data-heading attribute
    this.innerHTML = $($a.attr('href')).data('heading');
  });

  // zebra stripe all army list table bodies that don't contain another army list table
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