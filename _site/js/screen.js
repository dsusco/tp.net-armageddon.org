$(function () {
  'use strict';

  var $toc = $('.no-prince #table-of-contents'),
    $toc_ol = $('ol', $toc),
    $window = $(window, $('.no-prince'));

  // toggle the ToC's expansion
  $('.fa-plus-circle', $toc).click(function (e) {
    // if it's expanding, center the current position in the window
    if ($(e.target).hasClass('fa-plus-circle')) {
      $toc_ol.scrollTop($toc_ol.scrollTop() - ($window.height() / 2));
    }

    $toc.toggleClass('expanded');
    $('body').toggleClass('overflow-hidden');

    // if it's collapsing, trigger a scroll to ensure the correct current position
    if ($(e.target).hasClass('fa-minus-circle')) {
      $window.trigger('delayedScroll');
    }

    $(this).toggleClass('fa-minus-circle fa-plus-circle');
  });

  // up/down clicks
  $('.fa-chevron-circle-up, .fa-chevron-circle-down', $toc).click(function () {
    var $li = $('.current-position').parent();

    if ($(this).hasClass('fa-chevron-circle-up')) {
      $li = $li.prev();
    } else {
      $li = $li.next();
    }

    if ($li.length) { window.location.hash = $li.find('a').attr('href'); }
  });

  // ToC link clicks
  $('a', $toc_ol).click(function () {
    // if the ToC's expanded, close it
    $('.fa-minus-circle', $toc).click();
  });

  // window delayed scroll
  $window.on('delayedScroll', function () {
    var scrollTop = $(this).scrollTop();

    // clear the current position
    $('.current-position').removeClass('current-position');

    // scrolls the ToC to window's current heading
    try {
      $toc_ol.scrollTop(0).scrollTop($('a:not(.sr-only)', $toc_ol).filter(function () {
        return $(this).data('position') <= scrollTop;
      }).last().addClass('current-position').position().top);
    } catch (error) {
      $('a:not(.sr-only)', $toc_ol).first().addClass('current-position');
    }
  }).trigger('delayedScroll');

  // zebra stripe each of the army list tables
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

// A delayed scrolling event for jQuery.
(function () {
  'use strict';

  var uid = 'delayedScroll' + (+new Date());

  $.event.special.delayedScroll = {
    milliseconds: 200,
    setup: function () {
      var timer,
        handler = function (e) {
          var args = arguments,
            self = this;

          if (timer) { clearTimeout(timer); }

          timer = setTimeout(function () {
            timer = null;
            e.type = 'delayedScroll';
            $.event.dispatch.apply(self, args);
          }, $.event.special.delayedScroll.milliseconds);
        };

      $(this).bind('scroll', handler).data(uid, handler);
    },
    teardown: function () {
      $(this).unbind('scroll', $(this).data(uid));
    }
  };
}());