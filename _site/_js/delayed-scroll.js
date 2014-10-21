(function () {
  'use strict';

  var uid = 'delayedScroll' + (+new Date());

  $.event.special.delayedScroll = {
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
            e.type = 'delayedScroll';
            $.event.dispatch.apply(self, args);
          }, options.milliseconds);
        };

      $(this).bind('scroll', handler).data(uid, handler);
    },
    teardown: function () {
      $(this).unbind('scroll', $(this).data(uid));
    }
  };
}());