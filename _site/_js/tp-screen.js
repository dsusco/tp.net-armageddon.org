$(function () {
  'use strict';

  var $toc = $('#table-of-contents'),
    $toc_ol = $('ol', $toc),
    $window = $(window);

  // watch for ToC's expansion toggle
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

  // watch for prev/next clicks
  $('.fa-chevron-circle-up, .fa-chevron-circle-down', $toc).click(function () {
    var $li = $('.current-position').parent();

    if ($(this).hasClass('fa-chevron-circle-up')) {
      $li = $li.prev();

      while ($li.has('.sr-only').length) {
        $li = $li.prev();
      }
    } else {
      $li = $li.next();

      while ($li.has('.sr-only').length) {
        $li = $li.next();
      }
    }

    // this will trigger a delayed scroll
    if ($li.length) { window.location.hash = $li.find('a').attr('href'); }
  });

  // watch for ToC link click (which trigger a delayed scroll)
  $('a', $toc_ol).click(function () {
    // if the ToC's expanded, close it
    $('.fa-minus-circle', $toc).click();
  });

  // watch for footnote clicks to open the faq
  $('.footnote').each(function () {
    var
      $footnote = $(this),
      $faq = $footnote.next('.faq').hide().click(function () {
        // don't close a faq when it's clicked
        return false;
      });

    $footnote.click(function () {
      var slideUp = function (e) {
        $faq.slideUp();
        $window.unbind('click', slideUp)
      };

      $faq.slideToggle(function () {
        if ($faq.is(':visible')) {
          // watch for window clicks to close the open faq
          $window.click(slideUp)
        }
      });
    });
  });

  // watch for window scrolling
  $window.on('delayedScroll', {milliseconds: 100}, function () {
    var scrollTop = $(this).scrollTop();

    // clear the current position
    $('.current-position').removeClass('current-position');

    // scroll the ToC to the window's current heading
    try {
      $toc_ol.scrollTop(0).scrollTop($('a:not(.sr-only)', $toc_ol).filter(function () {
        return $(this).data('position') <= scrollTop;
      }).last().addClass('current-position').position().top);
    } catch (error) {
      // if no filtered a tags are found, use the first
      $('a:not(.sr-only)', $toc_ol).first().addClass('current-position');
    }
  });

  // watch for window resizes
  $window.on('delayedResize', {milliseconds: 100}, function () {
    // as the heading positions change and need to be updated in the ToC
    $('a', $toc_ol).each(function () {
      var $a = $(this);

      $a.data('position', Math.floor($($a.attr('href')).offset().top));
    });

    $window.trigger('delayedScroll');
  }).trigger('delayedResize');
});