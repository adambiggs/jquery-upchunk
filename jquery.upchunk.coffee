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
    url: '',
    fallback_id: '',
    chunk_size: 1024,
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

      @init()

    init: ->
      $(@element).on('drop', @drop).on('dragenter', @dragEnter).on('dragover', @dragOver).on('dragleave', @dragLeave)
      $(document).on('drop', @docDrop).on('dragenter', @docEnter).on('dragover', @docOver).on('dragleave', @docLeave)

    process: (i) =>
      next_file = =>
        next = @todoQ.pop()
        if next
          @processQ.splice(i, 1, next)
          @process(i)
        else
          #end

      next_chunk = =>
        start = chunk_size * n
        end = chunk_size * (n + 1)
        n += 1
        if file.mozSlice
          chunk = file.mozSlice(start, end)
        else
          chunk = file.webkitSlice(start, end)
        fd = new FormData
        fd.append(@opts.param_name, chunk)
        xhr = new XMLHttpRequest
        xhr.open('POST', @opts.url, true)
        xhr.send(fd)
        xhr.onload = ->
          if n <= chunks
            next_chunk()
          else
            next_file()

      file = @processQ[i]
      if @opts.max_file_size > 0 and file.size > 1048576 * @opts.max_file_size
        @opts.error(@errors.tooLarge)
        next()
        return false
      chunk_size = 1024 * @opts.chunk_size
      chunks = Math.ceil(file.size / chunk_size)
      n = 0
      next_chunk()

    drop: (e) =>
      #@opts.drop(e)
      @files = e.originalEvent.dataTransfer.files
      unless @files
        @opts.error(@errors.notSupported)
        false
      @processQ = [] ; @todoQ = []
      @todoQ.push(file) for file in @files
      for i in [0..@opts.queue_size]
        file = @todoQ.pop()
        if file
          @processQ.push(file)
          @process(i)
      e.preventDefault()
      false

    encode: (file_name, file_data, mime_type) =>
      dashes = '--'
      crlf = '\r\n'
      boundary = '------multipartformboundary' + (new Date).getTime()
      @encoded_file = ''
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
