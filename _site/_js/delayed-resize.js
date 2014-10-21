(function () {
  'use strict';

  var uid = 'delayedResize' + (+new Date());

  $.event.special.delayedResize = {
    defaults: { milliseconds: $.fx.speeds.fast },
    setup: function (data) {
      var timer,
        options = $.extend($.event.special.delayedScroll.defaults, data),
        handler = function (e) {
          var args = arguments,
            self = this;

          if (timer) { clearTimeout(timer); }

          timer = setTimeout(function () {
            timer = null;
            e.type = 'delayedResize';
            $.event.dispatch.apply(self, args);
          }, options.milliseconds);
        };

      $(this).bind('resize', handler).data(uid, handler);
    },
    teardown: function () {
      $(this).unbind('resize', $(this).data(uid));
    }
  };
}());