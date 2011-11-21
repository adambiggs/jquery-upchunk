(function() {

  ;

  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  (function($, window, document) {
    var Plugin, defaults, pluginName;
    pluginName = 'upchunk';
    defaults = {
      url: '',
      fallback_id: '',
      chunk_size: 1024,
      refresh_rate: 1000,
      param_name: 'file',
      max_file_size: 0,
      queue_size: 2,
      data: {},
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
        this.encode = __bind(this.encode, this);
        this.drop = __bind(this.drop, this);
        this.process = __bind(this.process, this);
        this.opts = $.extend({}, defaults, options);
        this._defaults = defaults;
        this._name = pluginName;
        this.errors = {
          notSupported: 'BrowserNotSupported',
          tooLarge: 'FileTooLarge'
        };
        this.init();
      }

      Plugin.prototype.init = function() {
        $(this.element).on('drop', this.drop).on('dragenter', this.dragEnter).on('dragover', this.dragOver).on('dragleave', this.dragLeave);
        return $(document).on('drop', this.docDrop).on('dragenter', this.docEnter).on('dragover', this.docOver).on('dragleave', this.docLeave);
      };

      Plugin.prototype.process = function(i) {
        var chunk_size, chunks, file, n, next_chunk, next_file,
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
          var chunk, end, fd, start, xhr;
          start = chunk_size * n;
          end = chunk_size * (n + 1);
          n += 1;
          if (file.mozSlice) {
            chunk = file.mozSlice(start, end);
          } else {
            chunk = file.webkitSlice(start, end);
          }
          fd = new FormData;
          fd.append(_this.opts.param_name, file);
          xhr = new XMLHttpRequest;
          xhr.open('POST', _this.opts.url, true);
          return xhr.send(fd);
        };
        file = this.processQ[i];
        if (this.opts.max_file_size > 0 && file.size > 1048576 * this.opts.max_file_size) {
          this.opts.error(this.errors.tooLarge);
          next();
          return false;
        }
        chunk_size = 1024 * this.opts.chunk_size;
        chunks = Math.ceil(file.size / chunk_size);
        n = 0;
        return next_chunk();
      };

      Plugin.prototype.drop = function(e) {
        var file, i, _i, _len, _ref, _ref2;
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

      Plugin.prototype.encode = function(file_name, file_data, mime_type) {
        var boundary, crlf, dashes, name, value, _len, _ref;
        dashes = '--';
        crlf = '\r\n';
        boundary = '------multipartformboundary' + (new Date).getTime();
        this.encoded_file = '';
        _ref = this.opts.data;
        for (value = 0, _len = _ref.length; value < _len; value++) {
          name = _ref[value];
          this.encoded_file += dashes;
          this.encoded_file += boundary;
          this.encoded_file += crlf;
          this.encoded_file += 'Content-Disposition: form-data; name=' + name + '"';
          this.encoded_file += crlf;
          this.encoded_file += crlf;
          this.encoded_file += value;
          this.encoded_file += crlf;
        }
        this.encoded_file += dashes;
        this.encoded_file += boundary;
        this.encoded_file += crlf;
        this.encoded_file += 'Content-Disposition: form-data; name="' + this.opts.param_name + '"';
        this.encoded_file += '; filename="' + file_name + '"';
        this.encoded_file += crlf;
        this.encoded_file += 'Content-Type: ' + mime_type;
        this.encoded_file += crlf;
        this.encoded_file += crlf;
        this.encoded_file += file_data;
        this.encoded_file += crlf;
        this.encoded_file += dashes;
        this.encoded_file += boundary;
        this.encoded_file += dashes;
        return this.encoded_file += crlf;
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
