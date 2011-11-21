(function() {

  ;

  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  (function($, window, document) {
    var Plugin, defaults, pluginName;
    pluginName = 'upchunk';
    defaults = {
      chunk_url: '',
      file_url: '',
      fallback_id: '',
      chunk_size: 1024,
      file_param: 'file',
      name_param: 'file_name',
      max_file_size: 0,
      queue_size: 2,
      data: {},
      refresh_rate: 1000,
      drop: function() {},
      dragEnter: function() {},
      dragOver: function() {},
      dragLeave: function() {},
      docEnter: function() {},
      docOver: function() {},
      docLeave: function() {},
      beforeEach: function() {},
      afterAll: function() {},
      rename: function() {},
      error: function(err) {
        return alert(err);
      },
      fileAdded: function() {},
      uploadStarted: function() {},
      chunkFinished: function() {},
      uploadFinished: function() {},
      progressUpdated: function() {}
    };
    Plugin = (function() {

      function Plugin(element, options) {
        this.element = element;
        this.docLeave = __bind(this.docLeave, this);
        this.docOver = __bind(this.docOver, this);
        this.docEnter = __bind(this.docEnter, this);
        this.docDrop = __bind(this.docDrop, this);
        this.dragLeave = __bind(this.dragLeave, this);
        this.dragOver = __bind(this.dragOver, this);
        this.dragEnter = __bind(this.dragEnter, this);
        this.drop = __bind(this.drop, this);
        this.process = __bind(this.process, this);
        this.opts = $.extend({}, defaults, options);
        this._defaults = defaults;
        this._name = pluginName;
        this.errors = {
          notSupported: 'BrowserNotSupported',
          tooLarge: 'FileTooLarge'
        };
        this.hash = function(s) {
          var char, hash, i, len, test;
          hash = 0;
          len = s.length;
          if (len === 0) return hash;
          for (i = 0; 0 <= len ? i <= len : i >= len; 0 <= len ? i++ : i--) {
            char = s.charCodeAt(i);
            test = ((hash << 5) - hash) + char;
            if (!isNaN(test)) hash = test & test;
          }
          return Math.abs(hash);
        };
        this.init();
      }

      Plugin.prototype.init = function() {
        $(this.element).on('drop', this.drop).on('dragenter', this.dragEnter).on('dragover', this.dragOver).on('dragleave', this.dragLeave);
        return $(document).on('drop', this.docDrop).on('dragenter', this.docEnter).on('dragover', this.docOver).on('dragleave', this.docLeave);
      };

      Plugin.prototype.process = function(i) {
        var chunk_size, chunks, file, n, next_chunk, next_file, send,
          _this = this;
        next_file = function() {
          var next;
          next = _this.todoQ.pop();
          if (next) {
            _this.processQ.splice(i, 1, next);
            return _this.process(i);
          } else {

          }
        };
        next_chunk = function() {
          var chunk, end, start;
          start = chunk_size * n;
          end = chunk_size * (n + 1);
          n += 1;
          if (file.mozSlice) {
            chunk = file.mozSlice(start, end);
          } else {
            chunk = file.webkitSlice(start, end);
          }
          return send(chunk, _this.opts.chunk_url);
        };
        send = function(chunk, url) {
          var fd, name, value, xhr, _ref;
          fd = new FormData;
          fd.append(_this.opts.file_param, chunk);
          fd.append(_this.opts.name_param, file.name);
          fd.append('hash', (_this.hash(file.name) + file.size).toString());
          _ref = _this.opts.data;
          for (name in _ref) {
            value = _ref[name];
            fd.append(name, value);
          }
          if (n === chunks) {
            fd.append('last', true);
          } else {
            fd.append('last', false);
          }
          xhr = new XMLHttpRequest;
          xhr.open('POST', url, true);
          xhr.send(fd);
          return xhr.onload = function() {
            if (typeof chunks !== "undefined" && chunks !== null) {
              if (n < chunks) {
                return next_chunk();
              } else {
                return next_file();
              }
            } else {
              return next_file();
            }
          };
        };
        file = this.processQ[i];
        if (this.opts.max_file_size > 0 && file.size > 1048576 * this.opts.max_file_size) {
          this.opts.error(this.errors.tooLarge);
          next_file();
          return false;
        }
        if (this.opts.file_url) {
          return send(file, this.opts.file_url);
        } else {
          chunk_size = 1024 * this.opts.chunk_size;
          chunks = Math.ceil(file.size / chunk_size);
          n = 0;
          return next_chunk();
        }
      };

      Plugin.prototype.drop = function(e) {
        var file, i, _i, _len, _ref, _ref2;
        this.docLeave(e);
        this.files = e.originalEvent.dataTransfer.files;
        if (!this.files) {
          this.opts.error(this.errors.notSupported);
          false;
        }
        this.processQ = [];
        this.todoQ = [];
        _ref = this.files;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          file = _ref[_i];
          this.todoQ.push(file);
        }
        for (i = 0, _ref2 = this.opts.queue_size; 0 <= _ref2 ? i <= _ref2 : i >= _ref2; 0 <= _ref2 ? i++ : i--) {
          file = this.todoQ.pop();
          if (file) {
            this.processQ.push(file);
            this.process(i);
          }
        }
        e.preventDefault();
        return false;
      };

      Plugin.prototype.dragEnter = function(e) {
        clearTimeout(this.timer);
        e.preventDefault();
        return this.opts.dragEnter(e);
      };

      Plugin.prototype.dragOver = function(e) {
        clearTimeout(this.timer);
        e.preventDefault();
        this.opts.docOver(e);
        return this.opts.dragOver(e);
      };

      Plugin.prototype.dragLeave = function(e) {
        clearTimeout(this.timer);
        this.opts.dragLeave(e);
        return e.stopPropagation();
      };

      Plugin.prototype.docDrop = function(e) {
        e.preventDefault();
        this.opts.docLeave(e);
        return false;
      };

      Plugin.prototype.docEnter = function(e) {
        clearTimeout(this.timer);
        e.preventDefault();
        this.opts.docEnter(e);
        return false;
      };

      Plugin.prototype.docOver = function(e) {
        clearTimeout(this.timer);
        e.preventDefault();
        this.opts.docOver(e);
        return false;
      };

      Plugin.prototype.docLeave = function(e) {
        var _this = this;
        return this.timer = setTimeout((function() {
          return _this.opts.docLeave(e);
        }), 200);
      };

      return Plugin;

    })();
    return $.fn[pluginName] = function(options) {
      return this.each(function() {
        if (!$.data(this, "plugin_" + pluginName)) {
          return $.data(this, "plugin_" + pluginName, new Plugin(this, options));
        }
      });
    };
  })(jQuery, window, document);

}).call(this);
