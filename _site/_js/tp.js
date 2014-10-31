$(function () {
  'use strict';

  var
    h,
    h1 = 0,
    h2 = 0,
    h3 = 0;

  $('html').toggleClass('js no-js');

  if (typeof Prince !== 'undefined') {
    $('html').toggleClass('no-prince prince');
  }

  $('h1[id], h2[id], h3[id]').each(function () {
    var $h = $(this),
      $a = $('<a>', { href: '#' + $h.prop('id') }).append($h.text());

    switch (this.tagName) {
      case 'H1':
        h1 += 1;
        h2 = 0;
        h3 = 0;
        h = h1 + '.0';
        break;
      case 'H2':
        h2 += 1;
        h3 = 0;
        h = h1 + '.' + h2;
        break;
      case 'H3':
        h3 += 1;
        h = h1 + '.' + h2 + '.' + h3;
        break;
    }

    $h.data('heading', h);

    $a.addClass(this.tagName.toLowerCase());

    if ($h.hasClass('no-count')) { $a.addClass('no-count'); }

    if ($h.hasClass('sr-only')) { $a.addClass('sr-only'); }

    $('#table-of-contents ol').append($('<li>').append($a));
  });

  $('main:not(.no-outline) section:not(#table-of-contents) a[href^="#"]').each(function () {
    var $a = $(this);

    this.innerHTML = $($a.attr('href')).data('heading');
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