//= require baseline
//= require plugins/jquery.zebraStripe.js

$(function () {
  var
    headingOffsets,
    navHeight = $('#nav').height(),
    $currentHeading = $('#current_heading'),
    $navLinks =
      $('#nav_menu')
        .modal({ open: false })
        // scroll the modal to the current heading
        .on('modal:opened', function (event) {
          $(this).scrollTop($navLinks.eq($currentHeading.data('nav-link-index')).offset().top);
        })
        .find('a[href^="#"]');

  function setHeadingOffets() {
    headingOffsets = $navLinks.toArray().map(function(navLink) {
        return document.getElementById(navLink.getAttribute('href').substr(1)).offsetTop;
      });

    $(window).trigger('scroll');
  }

  if ($navLinks.length) {
    $(window)
      // set the heading offsets array on load and resize
      .on('resize', setHeadingOffets)
      // set the current heading on scroll
      .on('scroll', function () {
        try {
          var navLinkIndex = headingOffsets.findIndex(function (offsetTop) {
              return offsetTop > document.documentElement.scrollTop + navHeight;
            }) - 1;

          // if no offset is greater than the document's scroll top, the index will be -2
          if (navLinkIndex === -2) {
            // set it to -1 to get the last heading
            navLinkIndex = -1;
          }

          $currentHeading
            .data('nav-link-index', navLinkIndex)
            .html($navLinks.eq(navLinkIndex).html());
        } catch (ignore) {}
      });

    setHeadingOffets();

    // close the nav links modal when a link is clicked
    $navLinks
      .on('click', function () {
        $(this).trigger('modal:close');
      });

    // jump to previous and next headings
    $('#nav .fa-chevron-circle-up')
      .on('click', function () {
        $navLinks.eq($currentHeading.data('nav-link-index') - 1).get(0).click();
      });

    $('#nav .fa-chevron-circle-down')
      .on('click', function () {
        $navLinks.eq($currentHeading.data('nav-link-index') + 1).get(0).click();
      });
  }

  $(document)
    // close FAQs when clicking outside of them
    .on('click', function (event) {
      if (!$(event.target).closest('.faq, [data-footnote]').length) {
        $('.faq:not([hidden])').trigger('accessibleToggle:hide');
      }
    })
    // close FAQs with Esc
    .on('keyup', function (event) {
      if (event.keyCode === 27) {
        $('.faq:not([hidden])').trigger('accessibleToggle:hide');
      }
    });

  // change anchor text to heading number if it exists
  $('.default-layout #main a[href]').each(function () {
    try {
      var number = $($(this).attr('href').match(/(#.+)$/).pop()).data('heading');

      if (number) {
        this.innerHTML = number;
      }
    } catch (e) {}
  });

  // toggle FAQs by clicking their headings
  $('aside.faq').accessibleToggle({ hidden: true, parent: '#main' });

  // zebra stripe all army list table bodies that don't contain another army list table
  $('table.army-list:not(:has(table.army-list)) > tbody').zebraStripe();
});
