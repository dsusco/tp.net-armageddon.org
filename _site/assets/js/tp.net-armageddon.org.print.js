---
include:
  - bower_components/jquery-2.2.4/dist/jquery.js
  - _site/_assets/javascripts/zebra-stripe.js
---
$(function () {
  'use strict';

  $('html')
    .first().toggleClass('js no-js');

  $('#nav').detach().insertAfter($('#copyright'));

  $('.default-layout #main a[href]').each(function () {
    try {
      var
        $a = $(this),
        $target = $($a.attr('href').match(/(#.+)$/).pop());

      // remove any path arguments from the anchor (keep links within PDF)
      if ($target.length) {
        $a.attr('href', '#' + $target.attr('id'));
      }

      // change anchor text to heading number if it exists
      if ($target.data('number')) {
        this.innerHTML = $target.data('number');
      }
    } catch (e) {}
  });

  // zebra stripe all army list table bodies that don't contain another army list table
  $('.table-army-list:not(:has(.table-army-list)) > tbody').zebraStripe();
});
