jQuery.fn.extend({
  accessibleToggle: function (accessibleToggleOptions = {}) {
    return this.each(function () {
      var
        $toggle = $(this),
        options = $.extend({
          hidingAnimation: '',
          showingAnimation: ''
        }, $toggle.data(), accessibleToggleOptions),
        $control,
        $parent;

      try {
        $control = $(options.control);
      } catch (e) {
        if (options.control.charAt(0) === '#') {
          $control = $(document.getElementById(options.control.substr(1)));
        }
      }

      try {
        $parent = $(options.parent).first()
      } catch (e) {
        if (options.parent.charAt(0) === '#') {
          $parent = $(document.getElementById(options.parent.substr(1)));
        }
      }

      function hide (event = null, extraParameters = {}) {
        var ariaLabelledby = '';

        // block while hiding
        if (!$toggle.hasClass('hiding')) {
          $toggle
            .addClass('hiding')
            .animateCss(options.hidingAnimation)
            .trigger('accessibleToggle:hiding');

          $control.addClass('hiding-toggle');

          try {
            // update all controls
            ariaLabelledby = $($toggle.attr('aria-labelledby').split(' ').map(function (id) {
                return document.getElementById(id);
              }))
              .removeClass('shown-toggle')
              .addClass('hidden-toggle')
              .attr('aria-expanded', false)
              .toArray().reduce(function (ariaLabelledby, el) {
                return ariaLabelledby + ' ' + el.getAttribute('id');
              }, '');
          } catch (ignore) {}

          // remove controls that are no longer on the page
          $toggle.attr('aria-labelledby', ariaLabelledby.trim());

          if ($toggle.hasEvent('animationend')) {
            // if there's an animation, let it complete before hiding
            $toggle.one('animationend', hideToggle);
          } else {
            hideToggle();
          }

          if (extraParameters.stopPropagation === true) {
            event.stopPropagation();
          }
        }
      }

      function hideToggle () {
        $control.removeClass('hiding-toggle');

        $toggle
          .prop('hidden', true)
          .removeClass('hiding')
          .trigger('accessibleToggle:hidden');
      }

      function show (event = null, extraParameters = {}) {
        var ariaLabelledby = '';

        // block while showing
        if (!$toggle.hasClass('showing')) {
          $toggle
            .addClass('showing')
            .animateCss(options.showingAnimation)
            .trigger('accessibleToggle:showing');

          $control.addClass('showing-toggle');

          try {

            // if a parent is defined, hide all other toggles in it
            $($parent.data('accessible-toggle-children'))
              .filter(':visible')
              .not($toggle)
                .trigger('accessibleToggle:hide.baseline', { stopPropagation: true });
          } catch (ignore) {}

          try {
            // update all controls
            ariaLabelledby = $($toggle.attr('aria-labelledby').split(' ').map(function (id) {
                return document.getElementById(id);
              }))
              .removeClass('hidden-toggle')
              .addClass('shown-toggle')
              .attr('aria-expanded', true)
              .toArray().reduce(function (ariaLabelledby, el) {
                return ariaLabelledby + ' ' + el.getAttribute('id');
              }, '');
          } catch (ignore) {}

          // remove controls that are no longer on the page
          $toggle
            .attr('aria-labelledby', ariaLabelledby.trim())
            .prop('hidden', false);

          if ($toggle.hasEvent('animationend')) {
            // if there's an animation, let it complete before triggering the shown event
            $toggle.one('animationend', showToggle);
          } else {
            showToggle();
          }

          if (extraParameters.stopPropagation === true) {
            event.stopPropagation();
          }
        }
      }

      function showToggle () {
        $control.removeClass('showing-toggle');

        $toggle
          .removeClass('showing')
          .trigger('accessibleToggle:shown');
      }

      function toggleClick (event) {
        $toggle.is(':visible') ? hide(event) : show(event);
      }

      $toggle
        .id('accessible_toggle')
        .addClass('accessible-toggle');

      $control
        .id('accessible_toggle_control')
        .addClass('accessible-toggle-control')
        .attr('aria-controls', function (index, attr) {
          try {
            attr = attr.split(' ')
          } catch (e) {
            attr = [];
          }

          if (attr.indexOf($toggle.attr('id')) < 0) {
            attr.push($toggle.attr('id'));
          }

          return attr.join(' ').trim();
        })
        .prop('disabled', false)
        .not('a[href], link[href], button, input, select, textarea')
          .attr('tabindex', 0);

      $parent
        .data('accessible-toggle-children', ($parent.data('accessible-toggle-children') || []).concat(this));

      $toggle
        .attr('aria-labelledby', function (index, attr) {
          try {
            attr = attr.split(' ')
          } catch (e) {
            attr = [];
          }

          $control.each(function () {
            var controlID = $(this).attr('id');

            if (attr.indexOf(controlID) < 0) {
              attr.push(controlID);
            }
          });

          return attr.join(' ').trim();
        });

      // check the toggle for show/hide events
      if (!$toggle.hasEventHandler('accessibleToggle:hide.baseline', hide) ||
          !$toggle.hasEventHandler('accessibleToggle:show.baseline', show) ) {
        $toggle
          .on('accessibleToggle:hide.baseline', hide)
          .on('accessibleToggle:show.baseline', show);

        $(window)
          .on('resize', function () {
            var hidden = options.hidden === undefined ? $toggle.is(':hidden') : eval(options.hidden);

            $toggle
              .prop('hidden', hidden);

            $control
              .removeClass('shown-toggle hidden-toggle')
              .addClass(hidden ? 'hidden-toggle' : 'shown-toggle')
              .attr('aria-expanded', !hidden);
          })
          .trigger('resize');
      }

      // check the control for click events
      if (!$control.hasEventHandler('click', toggleClick)) {
        $control
          .on('click', toggleClick)
          .not('button, [type="button"], [type="image"], [type="reset"], [type="submit"]')
            .on('keypress', function (event) {
              if (event.key === 'Enter') {
                toggleClick(event);
              }
            });
      }
    });
  }
});
