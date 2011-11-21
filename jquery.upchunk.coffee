#  Project: Upchunk
#  Description: An HTML5 file uploader with chunk and fallback support
#  Author: Chris Bolton
#  License: WTFPL

# the semi-colon before function invocation is a safety net against concatenated
# scripts and/or other plugins which may not be closed properly.
``
(($, window, document) ->

  pluginName = 'upchunk'
  defaults =
    fallback_id: '',
    url: '',
    refresh_rate: 1000,
    param_name: 'file',
    max_file_size: 0,
    queue_size: 2,
    data: {},
    drop: ->,
    dragEnter: ->,
    dragOver: ->,
    dragLeave: ->,
    docEnter: ->,
    docOver: ->,
    docLeave: ->,
    beforeEach: ->,
    afterAll: ->
    rename: ->,
    error: (err) -> alert err,
    fileAdded: ->,
    uploadStarted: ->,
    uploadFinished: ->,
    progressUpdated: ->
  errors =
    notSupported: 'BrowserNotSupported',
    tooLarge: 'FileTooLarge'

  class Plugin
    constructor: (@element, options) ->
      @opts = $.extend {}, defaults, options

      @_defaults = defaults
      @_name = pluginName

      @timer

      @init()

    init: ->
      $(@element).on('drop', drop).on('dragenter', @dragEnter).on('dragover', @dragOver).on('dragleave', @dragLeave)
      $(document).on('drop', @docDrop).on('dragenter', @docEnter).on('dragover', @docOver).on('dragleave', @docLeave)

      drop = (e) ->
        @opts.drop(e)
        files = e.dataTransfer.files
        unless files
          @opts.error(errors.notSupported)
          false
        files_count = files.length
        upload()
        e.preventDefault()
        false

      upload = ->
        console.log(files)

    dragEnter: (e) =>
      clearTimeout(@timer)
      e.preventDefault()
      @opts.dragEnter(e)

    dragOver: (e) =>
      clearTimeout(@timer)
      e.preventDefault()
      @opts.docOver(e)
      @opts.dragOver(e)

    dragLeave: (e) =>
      clearTimeout(@timer)
      @opts.dragLeave(e)
      e.stopPropagation()

    docDrop: (e) =>
      e.preventDefault()
      @opts.docLeave(e)
      false

    docEnter: (e) =>
      clearTimeout(@timer)
      e.preventDefault()
      @opts.docEnter(e)
      false

    docOver: (e) =>
      clearTimeout(@timer)
      e.preventDefault()
      @opts.docOver(e)
      false

    docLeave: (e) =>
      @timer = setTimeout((=> @opts.docLeave(e)), 200)

  # A really lightweight plugin wrapper around the constructor,
  # preventing against multiple instantiations
  $.fn[pluginName] = (options) ->
    this.each ->
      if !$.data(this, "plugin_#{pluginName}")
        $.data(this, "plugin_#{pluginName}", new Plugin(this, options))
)(jQuery, window, document)
