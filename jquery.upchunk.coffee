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
    chunkFinished: ->,
    uploadFinished: ->,
    progressUpdated: ->

  class Plugin
    constructor: (@element, options) ->
      @opts = $.extend {}, defaults, options

      @_defaults = defaults
      @_name = pluginName

      @errors =
        notSupported: 'BrowserNotSupported',
        tooLarge: 'FileTooLarge'

      @timer
      @todoQ
      @processingQ
      @doneQ
      @files
      @encoded_file = ''

      @init()

    init: ->
      $(@element).on('drop', @drop).on('dragenter', @dragEnter).on('dragover', @dragOver).on('dragleave', @dragLeave)
      $(document).on('drop', @docDrop).on('dragenter', @docEnter).on('dragover', @docOver).on('dragleave', @docLeave)

    upload: ->

    drop: (e) =>
      #@opts.drop(e)
      @files = e.originalEvent.dataTransfer.files
      unless @files
        @opts.error(@errors.notSupported)
        false
      @upload()
      e.preventDefault()
      false

    encode: (file_name, file_data, mime_type) =>
      dashes = '--'
      crlf = '\r\n'
      boundary = '------multipartformboundary' + (new Date).getTime()
      for name, value in @opts.data
        @encoded_file += dashes
        @encoded_file += boundary
        @encoded_file += crlf
        @encoded_file += 'Content-Disposition: form-data; name=' + name + '"'
        @encoded_file += crlf
        @encoded_file += crlf
        @encoded_file += value
        @encoded_file += crlf

      @encoded_file += dashes
      @encoded_file += boundary
      @encoded_file += crlf
      @encoded_file += 'Content-Disposition: form-data; name="' + @opts.param_name + '"'
      @encoded_file += '; filename="' + file_name + '"'
      @encoded_file += crlf

      @encoded_file += 'Content-Type: ' + mime_type
      @encoded_file += crlf
      @encoded_file += crlf

      @encoded_file += file_data
      @encoded_file += crlf

      @encoded_file += dashes
      @encoded_file += boundary
      @encoded_file += dashes
      @encoded_file += crlf

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
