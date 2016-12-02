---
include:
  - bower_components/jquery/dist/jquery.js
  - bower_components/bootstrap/dist/js/bootstrap.js
---
$(function () {
  'use strict';

  var
    $body = $('body'),
    $faqs = $('.faq'),
    $nav = $('#nav');

  // store body's original overflow value
  $body.data('overflow', $body.css('overflow'));

  $('html')
    .first().toggleClass('js no-js')
    // scroll the body up to see the heading text when an anchor is clicked
    .on('click', 'a[href*="#"]', function () {
      setTimeout(function () {
        $body.scrollTop($body.scrollTop() - +$body.data('offset') + 1);
      }, 1);
    })
    // close open FAQs when clicking outside of them
    .on('click', function (event) {
      $faqs.not($(event.target).closest('.faq')).collapse('hide');
    })
    // close open FAQs with Esc
    .on('keyup', function (event) {
      if (event.keyCode === 27) {
        $faqs.collapse('hide');
      }
    });

  $nav
    // store the nav's original height
    .data('height', $nav.css('height'))
    // scroll the nav when .active changes
    .on('activate.bs.scrollspy', function () {
      var $active = $('.active', $nav);

      if (!$active.length) {
        $active = $('li:first-child', $nav);
      }

      $nav.scrollTop(0).scrollTop($active.position().top);
    })
    .on('click', 'i.fa, a', function (event) {
      var
        $fa = $('i', $nav);

      // shrink the nav on fa-plus/minus-circle or link click
      if ($nav.hasClass('expanded')) {
        $nav
          .animate({ height: $nav.data('height') }, {
            complete: function () {
              $nav
                .removeClass('expanded')
                .trigger('activate.bs.scrollspy');
              $body.css({ overflow : $body.data('overflow') });
              $fa.toggleClass('fa-plus-circle fa-minus-circle');
            },
            duration: 'fast'
          });
      // expand the nav on fa-plus/minus-circle click only
      } else if (event.target.tagName === 'I') {
        $fa.toggleClass('fa-plus-circle fa-minus-circle');
        $body.css({ overflow : 'hidden' });

        $nav
          .addClass('expanded')
          .animate({ height: '100%' }, {
            duration: 'fast'
          });
      }
    })
    // update the nav on load
    .trigger('activate.bs.scrollspy');

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
