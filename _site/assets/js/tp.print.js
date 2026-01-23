// require plugins/jquery.zebraStripe.js

$(function () {
  'use strict';

  // move the ToC to the proper location
  $('#nav').detach().insertAfter($('#copyright'));

  $('._default_layout #main a[href*="#"]').each(function () {
    var $target = $(this.getAttribute('href').match(/(#.+)$/).pop());

    if ($target.length) {
      // remove any path arguments from the anchor (keep links within PDF)
      this.setAttribute('href', '#' + $target.attr('id'));

      // change anchor text to heading number if it exists
      if ($target.data('heading') && this.innerHTML.indexOf($target.data('heading')) < 0) {
        this.innerHTML = $target.data('heading');
      }
    } else {
      // of the target isn't in the PDF, link back to the TP site
      this.setAttribute('href', 'http://tp.net-armageddon.org' + this.getAttribute('href'));
    }
  });

  // zebra stripe all army list table bodies that don't contain another army list table
  //$('table._army_list:not(:has(table._army_list)) > tbody').zebraStripe();
  $('table._army_list:not(:has(table._army_list)) > tbody').each(function () {
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
        $tr.addClass('_bordered');
      }

      if (stripe) {
        $tr.addClass('_striped');
      }
    });
  });
});
