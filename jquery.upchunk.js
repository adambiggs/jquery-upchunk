(function() {

  ;

  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  (function($, window, document) {
    var Plugin, defaults, errors, pluginName;
    pluginName = 'upchunk';
    defaults = {
      fallback_id: '',
      url: '',
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
      uploadFinished: function() {},
      progressUpdated: function() {}
    };
    errors = {
      notSupported: 'BrowserNotSupported',
      tooLarge: 'FileTooLarge'
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
        this.opts = $.extend({}, defaults, options);
        this._defaults = defaults;
        this._name = pluginName;
        this.timer;
        this.init();
      }

      Plugin.prototype.init = function() {
        $(this.element).on('drop', this.drop).on('dragenter', this.dragEnter).on('dragover', this.dragOver).on('dragleave', this.dragLeave);
        return $(document).on('drop', this.docDrop).on('dragenter', this.docEnter).on('dragover', this.docOver).on('dragleave', this.docLeave);
      };

      Plugin.prototype.upload = function() {
        console.log(files);
        return console.log(errors);
      };

      Plugin.prototype.drop = function(e) {
        var files, files_count;
        files = e.originalEvent.dataTransfer.files;
        if (!files) {
          this.opts.error(errors.notSupported);
          false;
        }
        files_count = files.length;
        console.log(errors);
        this.upload();
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
