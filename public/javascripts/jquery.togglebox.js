/**
 * jQuery UI Toggleboxes 1.8
 *
 * Copyright (c) 2010 Michael Keck (http://www.michaelkeck.de/)
 *
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * This plugin is a port with modifications from the original
 * jQuery UI Accordion 1.8
 *
 * Copyright (c) 2009 AUTHORS.txt (http://jqueryui.com/about)
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * http://docs.jquery.com/UI/Accordion
 *
 *
 * Modifications:
 *
 *    Use this to get boxes like the accordians, but the
 *    opened boxes still stay opened and the closed boxes
 *    still stay closed.
 *    I know, that there are perhaps some nearly same plugins
 *    like mine. But note: mine uses the same css-styles as
 *    accordion and the intit is nearly the same.
 *
 *
 * Usage:
 *
 *      $("#toggleboxes1").toggleboxes({
 *          header: "h3",
 *          icons: {
 *              'header': 'ui-icon-triangle-1-s',
 *              'headerSelected': 'ui-icon-triangle-1-n'
 *         }
 *      });
 *      // ore use a different class
 *      $("#toggleboxes2").toggleboxes({
 *          header: "h3",
 *          boxclass: 'ui-togglebox',
 *          icons: {
 *              'header': 'ui-icon-triangle-1-s',
 *              'headerSelected': 'ui-icon-triangle-1-n'
 *         }
 *      });
 *
 *
 * Depends:
 *	jquery.ui.core.js
 *	jquery.ui.widget.js
 */
(function($) {

    $.widget('ui.toggleboxes', {
    	options: {
    		active:      0,
    		animated:    'slide',
    		autoHeight:  true,
    		clearStyle:  false,
    		collapsible: false,
    		event:       'click',
    		fillSpace:   false,
    		header:      '> li > :first-child,> :not(li):even',
            boxclass:    'ui-accordion',
    		icons: {
    			header:         'ui-icon-triangle-1-e',
    			headerSelected: 'ui-icon-triangle-1-s'
    		},
    		navigation: false,
    		navigationFilter: function() {
    			return this.href.toLowerCase() == location.href.toLowerCase();
    		}
    	},
    	_create: function() {
    		var o = this.options, self = this;
    		this.running = 0;
    		this.element.addClass(o.boxclass + ' ui-widget ui-helper-reset');
    		/* in lack of child-selectors in CSS we need to mark top-LIs in a UL-accordion for some IE-fix */
    		if (this.element[0].nodeName == 'UL') {
    			this.element.children('li').addClass(o.boxclass + '-li-fix');
    		}
    		this.headers = this.element.find(o.header).addClass(o.boxclass + '-header ui-helper-reset ui-state-default ui-corner-all')
    			.bind('mouseenter.toggleboxes', function(){ $(this).addClass('ui-state-hover'); })
    			.bind('mouseleave.toggleboxes', function(){ $(this).removeClass('ui-state-hover'); })
    			.bind('focus.toggleboxes', function(){ $(this).addClass('ui-state-focus'); })
    			.bind('blur.toggleboxes', function(){ $(this).removeClass('ui-state-focus'); });
    		this.headers.next().addClass(o.boxclass + '-content ui-helper-reset ui-widget-content ui-corner-bottom');
    		if (o.navigation) {
    			var current = this.element.find('a').filter(o.navigationFilter);
    			if (current.length) {
    				var header = current.closest('.' + o.boxclass + '-header');
    				if (header.length) {
    					/* anchor within header */
    					this.active = header;
    				} else {
    					/* anchor within content */
    					this.active = current.closest('.' + o.boxclass + '-content').prev();
    				}
    			}
    		}
    		this.active = this._findActive(this.active || o.active).toggleClass('ui-state-default').toggleClass('ui-state-active').toggleClass('ui-corner-all').toggleClass('ui-corner-top');
    		this.active.next().addClass(o.boxclass + '-content-active');
    		/* Append icon elements */
    		this._createIcons();
    		/* IE7-/Win - Extra vertical space in lists fixed */
    		if ($.browser.msie) {
    			this.element.find('a').css('zoom', '1');
    		}
    		this.resize();
    		/* ARIA */
    		this.element.attr('role', 'tablist');
    		this.headers
    			.attr('role', 'tab')
    			.bind('keydown', function(event) { return self._keydown(event); })
    			.next()
    			.attr('role', 'tabpanel');
    		this.headers
    			.not(this.active || '')
    			.attr('aria-expanded', 'false')
    			.attr('tabIndex', '-1')
    			.next()
    			.hide();
    		/* make sure at least one header is in the tab order */
    		if (!this.active.length) {
    			this.headers.eq(0).attr('tabIndex', '0');
    		} else {
    			this.active.attr('aria-expanded', 'true').attr('tabIndex', '0');
    		}
    		/* only need links in taborder for Safari */
    		if (!$.browser.safari) {
    			this.headers.find('a').attr('tabIndex', '-1');
            }
    		if (o.event) {
    			this.headers.bind((o.event) + '.toggleboxes', function(event) {
    				self._clickHandler.call(self, event, this);
    				event.preventDefault();
    			});
    		}
    	},

    	_createIcons: function() {
    		var o = this.options;
    		if (o.icons) {
    			$('<span/>').addClass('ui-icon ' + o.icons.header).prependTo(this.headers);
    			this.active.find('.ui-icon').toggleClass(o.icons.header).toggleClass(o.icons.headerSelected);
    			this.element.addClass(o.boxclass + '-icons');
    		}
    	},

    	_destroyIcons: function() {
    		this.headers.children('.ui-icon').remove();
    		this.element.removeClass(o.boxclass + '-icons');
    	},

    	destroy: function() {
    		var o = this.options;
    		this.element
    			.removeClass(o.boxclass + ' ui-widget ui-helper-reset')
    			.removeAttr('role')
    			.unbind('.toggleboxes')
    			.removeData('toggleboxes');
    		this.headers
    			.unbind('.toggleboxes')
    			.removeClass(o.boxclass + '-header ui-helper-reset ui-state-default ui-corner-all ui-state-active ui-corner-top')
    			.removeAttr('role').removeAttr('aria-expanded').removeAttr('tabindex');
    		this.headers.find('a').removeAttr('tabindex');
    		this._destroyIcons();
    		var contents = this.headers.next().css('display', '').removeAttr('role').removeClass('ui-helper-reset ui-widget-content ui-corner-bottom ' + o.boxclass + '-content ' + o.boxclass + '-content-active');
    		if (o.autoHeight || o.fillHeight) {
    			contents.css('height', '');
    		}
    		return this;
    	},

    	_setOption: function(key, value) {
    		$.Widget.prototype._setOption.apply(this, arguments);
    		if (key == 'active') {
    			this.activate(value);
    		}
    		if (key == 'icons') {
    			this._destroyIcons();
    			if (value) {
    				this._createIcons();
    			}
    		}
    	},

    	_keydown: function(event) {
    		var o = this.options, keyCode = $.ui.keyCode;
    		if (o.disabled || event.altKey || event.ctrlKey) {
    			return;
            }
    		var length = this.headers.length;
    		var currentIndex = this.headers.index(event.target);
    		var toFocus = false;
    		switch(event.keyCode) {
    			case keyCode.RIGHT:
    			case keyCode.DOWN:
    				toFocus = this.headers[(currentIndex + 1) % length];
    				break;
    			case keyCode.LEFT:
    			case keyCode.UP:
    				toFocus = this.headers[(currentIndex - 1 + length) % length];
    				break;
    			case keyCode.SPACE:
    			case keyCode.ENTER:
    				this._clickHandler({ target: event.target }, event.target);
    				event.preventDefault();
    		}
    		if (toFocus) {
    			$(event.target).attr('tabIndex', '-1');
    			$(toFocus).attr('tabIndex', '0');
    			toFocus.focus();
    			return false;
    		}
    		return true;
    	},

    	resize: function() {
    		var o = this.options, maxHeight;
            if (o.fillSpace) {
                if ($.browser.msie) {
                    var defOverflow = this.element.parent().css('overflow');
                    this.element.parent().css('overflow', 'hidden');
                }
                maxHeight = this.element.parent().height();
                if ($.browser.msie) {
                    this.element.parent().css('overflow', defOverflow);
                }
                this.headers.each(function() {
                    maxHeight -= $(this).outerHeight(true);
                });
                this.headers.next().each(function() {
                    $(this).height(Math.max(0, maxHeight - $(this).innerHeight() + $(this).height()));
                }).css('overflow', 'auto');
            } else if (o.autoHeight) {
                maxHeight = 0;
                this.headers.next().each(function() {
                    maxHeight = Math.max(maxHeight, $(this).height());
                }).height(maxHeight);
            }
            return this;
        },

        activate: function(index) {
            /* TODO this gets called on init, changing the option without an explicit call for that */
            this.options.active = index;
            /* call clickHandler with custom event */
            var active = this._findActive(index)[0];
            this._clickHandler({ target: active }, active);
            return this;
        },

        _findActive: function(selector) {
            return selector
                ? typeof selector == 'number'
                    ? this.headers.filter(':eq(' + selector + ')')
                    : this.headers.not(this.headers.not(selector))
                : selector === false
                    ? $([])
                    : this.headers.filter(':eq(0)');
        },

    	/* TODO isn't event.target enough? why the seperate target argument? */
        _clickHandler: function(event, target) {
            var o = this.options;
            if (o.disabled) {
                return false;
            }
            var h = $(event.currentTarget || target);
			if(h.next().length == 0 && o.navigation) {
				var go = h.attr('href');
				if(typeof go == "undefined") {
					go = h.children('a').attr('href');
				}
				window.location = go;
			}
            if ((h.attr('aria-expanded') == 'true')) {
                h.removeClass('ui-state-active ui-corner-top').addClass('ui-state-default ui-corner-all').find('.ui-icon').removeClass(o.icons.headerSelected).addClass(o.icons.header);
                var toHide = h.next(),
                    data = {
                        options: o
                    },
                    toShow = $([]),
                    down = 1;
                h.attr('aria-expanded', 'false');
            } else {
                h.removeClass('ui-state-default ui-corner-all').addClass('ui-state-active ui-corner-top').find('.ui-icon').removeClass(o.icons.header).addClass(o.icons.headerSelected);
                h.next().removeClass(o.boxclass + '-content-active').addClass(o.boxclass + '-content-active');
                var toShow = h.next(),
                    data = {
                        options: o
                    },
                    toHide = $([]),
                    down = 0;
                h.attr('aria-expanded', 'true');
            }
            if (this.running) {
                return false;
            }
            this._toggle(toShow, toHide, data, down);
            return false;
        },

        _toggle: function(toShow, toHide, data, down) {
            var t = this, o = t.options;
            t.toShow = toShow;
            t.toHide = toHide;
            t.data = data;
            var complete = function() {
                if (!t) {
                    return;
                }
                return t._completed.apply(t, arguments);
            };
            t._trigger('changestart', null, t.data);
            t.running = toHide.size() === 0 ? toShow.size() : toHide.size();
            if (o.animated) {
                var animOptions = {
                    toShow: toShow,
                    toHide: toHide,
                    complete: complete,
                    down: down,
                    autoHeight: o.autoHeight || o.fillSpace
                };
                if (!o.proxied) {
                    o.proxied = o.animated;
                }
                if (!o.proxiedDuration) {
                    o.proxiedDuration = o.duration;
                }
                o.animated = $.isFunction(o.proxied) ? o.proxied(animOptions) : o.proxied;
                o.duration = $.isFunction(o.proxiedDuration) ? o.proxiedDuration(animOptions) : o.proxiedDuration;
                var animations = $.ui.toggleboxes.animations, duration = o.duration, easing = o.animated;
                if (!animations[easing]) {
                    animations[easing] = function(options) {
                        this.slide(options, {
                            easing: easing,
                            duration: duration || 700
                        });
                    };
                }
                animations[easing](animOptions);
            } else {
                toHide.hide();
                toShow.show();
                complete(true);
            }
            toHide.prev().attr('aria-expanded', 'false').attr('tabIndex', '-1').blur();
            toShow.prev().attr('aria-expanded', 'true').attr('tabIndex', '0').focus();
        },

    	_completed: function(cancel) {
    		var o = this.options;
    		this.running = cancel ? 0 : --this.running;
    		if (this.running) {
                return;
            }
            if (o.clearStyle) {
                this.toShow.add(this.toHide).css({ 'height': '', 'overflow': ''	});
            }
            /* other classes are removed before the animation; this one needs to stay until completed */
            this.toHide.removeClass(o.boxclass + '-content-active');
            this._trigger('change', null, this.data);
        }

    });


    $.extend($.ui.toggleboxes, {
    	version: '1.8',
    	animations: {
    		slide: function(options, additions) {
    			options = $.extend({
    				easing: 'swing',
    				duration: 300
    			}, options, additions);
    			if (!options.toHide.size()) {
    				options.toShow.animate({ 'height' : 'show'}, options);
    				return;
    			}
    			if (!options.toShow.size()) {
    				options.toHide.animate({ 'height' : 'hide'}, options);
    				return;
    			}
    			var overflow = options.toShow.css('overflow'),
    				percentDone = 0,
    				showProps = {},
    				hideProps = {},
    				fxAttrs = [ 'height', 'paddingTop', 'paddingBottom' ],
    				originalWidth;
    			/* fix width before calculating height of hidden element */
    			var s = options.toShow;
    			originalWidth = s[0].style.width;
    			s.width( parseInt(s.parent().width(),10) - parseInt(s.css('paddingLeft'), 10) - parseInt(s.css('paddingRight'), 10) - (parseInt(s.css('borderLeftWidth'), 10) || 0) - (parseInt(s.css('borderRightWidth'), 10) || 0) );

    			$.each(fxAttrs, function(i, prop) {
    				hideProps[prop] = 'hide';
    				var parts = ('' + $.css(options.toShow[0], prop)).match(/^([\d+-.]+)(.*)$/);
    				showProps[prop] = {
    					'value': parts[1],
    					'unit' : parts[2] || 'px'
    				};
    			});
    			options.toShow.css({ 'height': 0, 'overflow': 'hidden' }).show();
    			options.toHide.filter(':hidden').each(options.complete).end().filter(':visible').animate(hideProps,{
    				step: function(now, settings) {
    					/**
                         * only calculate the percent when animating height
                         * IE gets very inconsistent results when animating elements
                         * with small values, which is common for padding
                         */
    					if (settings.prop == 'height') {
    						percentDone = ( settings.end - settings.start === 0 ) ? 0 : (settings.now - settings.start) / (settings.end - settings.start);
    					}
    					options.toShow[0].style[settings.prop] = (percentDone * showProps[settings.prop].value) + showProps[settings.prop].unit;
    				},
    				duration: options.duration,
    				easing: options.easing,
    				complete: function() {
    					if (!options.autoHeight) {
    						options.toShow.css('height', '');
    					}
    					options.toShow.css('width', originalWidth);
    					options.toShow.css({'overflow': overflow});
    					options.complete();
    				}
    			});
    		},
    		bounceslide: function(options) {
    			this.slide(options, {
    				easing: options.down ? 'easeOutBounce' : 'swing',
    				duration: options.down ? 1000 : 200
    			});
    		}
    	}
    });

})(jQuery);