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
    chunk: false,
    fallback_id: '',
    chunk_size: 1024,
    file_param: 'file',
    name_param: 'file_name',
    headers: {},
    max_file_size: 0,
    queue_size: 2,
    processNextImmediately: false,
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
    rename: (file) -> file.name,
    error: (err) -> alert err,
    fileAdded: ->,
    uploadStarted: ->,
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
        uploadHalted: 'UploadHalted'

      @hash = (s) ->
        hash = 0
        len = s.length
        return hash if len == 0
        for i in [0..len]
          char = s.charCodeAt(i)
          test = ((hash<<5)-hash)+char
          hash = test & test unless isNaN(test)
        Math.abs(hash)

      @init()

    init: ->
      @processQ = []
      @todoQ = []

      $(@element).on('drop', @drop).on('dragenter', @dragEnter).on('dragover', @dragOver).on('dragleave', @dragLeave)
      $(document).on('drop', @docDrop).on('dragenter', @docEnter).on('dragover', @docOver).on('dragleave', @docLeave)

      $('#' + @opts.fallback_id).change( @drop )

    process: (file) =>
      next_file = =>
        # Remove file element from list
        @processQ.splice(@processQ.indexOf(file),1)

        # ... and go to the next
        next = @todoQ.shift()
        if next
          next_hash = (@hash(next.name) + next.size).toString()
          @opts.uploadStarted(next, next_hash)
          @processQ.push(next)
          @process(next)

      progress = (e) =>
        old = 0 if !old?
        if n?
          pchunk = chunk_size * 100 / file.size
          percentage = Math.floor(((e.loaded * 100) / file.size) + (n - 1) * pchunk)
        else
          percentage = Math.floor(e.loaded * 100 / e.total)
        percentage = 100 if percentage > 100
        if percentage > old
          old = percentage
          hash = (@hash(file.name) + file.size).toString()
          @opts.progressUpdated(file, hash, percentage)
        next_file() if percentage == 100 && @opts.processNextImmediately

      next_chunk = =>
        start = chunk_size * n
        end = chunk_size * (n + 1)
        n += 1
        if file.slice
          chunk = file.slice(start, end)
        else if file.mozSlice
          chunk = file.mozSlice(start, end)
        else if file.webkitSlice
          chunk = file.webkitSlice(start, end)
        else
          chunk = file
          chunks = 1
        send(chunk, @opts.url)

      send = (chunk, url) =>
        hash = (@hash(file.name) + file.size).toString()
        if @opts.beforeEach() is false
          @opts.error(@errors.uploadHalted)
          next_file()
          return false
        fd = new FormData
        fd.append(@opts.file_param, chunk)
        fd.append(@opts.name_param, @opts.rename(file))
        fd.append('hash', hash)
        for name, value of @opts.data
          if typeof value == 'function'
            fd.append(name, value())
          else
            fd.append(name, value)
        if n == 1
          fd.append('first', true)
        else
          fd.append('first', false)
        if n == chunks
          fd.append('last', true)
        else
          fd.append('last', false)
        xhr = new XMLHttpRequest
        xhr.open('POST', url, true)
        for key,value of @opts.headers
          xhr.setRequestHeader(key, value)
        xhr.upload.addEventListener('progress', progress, false)
        xhr.send(fd)
        xhr.onload = =>
          if chunks? && n < chunks
            next_chunk()
          else
            try response = $.parseJSON(xhr.responseText)
            if response?
              @opts.uploadFinished(file, hash, response)
            else
              @opts.uploadFinished(file, hash)
            next_file() unless @opts.processNextImmediately
          @opts.afterAll() if @processQ.length == 0


      if @opts.max_file_size > 0 && file.size > 1048576 * @opts.max_file_size
        @opts.error(@errors.tooLarge)
        next_file()
        return false
      if @opts.chunk == false
        send(file, @opts.url)
      else
        chunk_size = 1024 * @opts.chunk_size
        chunks = Math.ceil(file.size / chunk_size)
        n = 0
        next_chunk()


    drop: (e) =>
      @docLeave(e)
      @opts.drop(e)
      @files = if e.originalEvent.dataTransfer? then e.originalEvent.dataTransfer.files else e.target.files
      unless @files
        @opts.error(@errors.notSupported)
        false

      @todoQ.push(file) for file in @files
      while @todoQ.length and @processQ.length < @opts.queue_size
        file = @todoQ.shift()
        if file
          hash = (@hash(file.name) + file.size).toString()
          @opts.uploadStarted(file, hash)
          @processQ.push(file)
          @process(file)
      e.preventDefault()
      false

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
