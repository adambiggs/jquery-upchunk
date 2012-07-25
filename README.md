Upchunk _- a modern file upload plugin for jQuery_
===========================

Features
-------------

- HTML5 drag n' drop capabilities
- HTML5 chunk support (for large files)
- Standard file upload window fallback option (soon to dynamically fallback to an HTML4-compatible version when appropriate)

Usage
-----

Values seen below are defaults.

```javascript

$('#dropzone').upchunk({
  url: '',                                          // the url the file (or chunks) will be sent to
                                                      // there will be two additional parameters- 'last' and 'first'
                                                      // which specify whether the chunk sent is the first and/or last, respectively
  chunk: false,                                     // whether or not files will be sent to the server in chunks
  chunk_size: 1024,                                 // the size of each chunk
  fallback_id: '',                                  // an identifier of a standard file input field to optionally interface with the plugin
  file_param: 'file',                               // the name of the parameter the file will have when sent to the server
  name_param: 'file_name',                          // the name of the parameter the file name will have when sent to the server
  max_file_size: 0,                                 // the maximum size of each uploaded file, 0 for infinite
  queue_size: 2,                                    // the maximum amount of files to upload to the server at once
  processNextImmediately: false,                    // whether to start processing the next file immediately once progress reaches 100% instead of waiting for the server's response
  data: {},                                         // additional parameters to be sent to the server
  // functions that will be executed...
  drop: function(e){},                              // when the files are dropped
  dragEnter: function(e){},                         // when files are dragged over the dropzone
  dragLeave: function(e){},                         // when dragged files leave the dropzone
  docEnter: function(e){},                          // when dragged files enter the browser window
  docLeave: function(e){},                          // when dragged files leave the browser window
  beforeEach: function(){},                         // before each file begins uploading, will throw 'UploadHalted' error if beforeEach returns false
  afterAll: function(){},                           // after all files are finished uploading
  rename: function(file) {return file.name},                   // to rename the file before being sent to the server
  error: function(err) { alert(err) },              // in response to errors; err can be one of the following: ['BrowserNotSupported', 'FileTooLarge', 'UploadHalted']
  uploadStarted: function(file, hash){},            // when an upload starts
  uploadFinished: function(file, hash, response){}, // when an upload finishes
  progressUpdated: function(file, hash, progress){} // each percentage update (soon to incorporate a refresh_rate parameter instead)
})

```

Notes & Contributions
-------------
_note:_ This is a fairly new plugin. If you experience any issues please don't hesitate to open up an issue and I'll resolve it asap :).

_contribution:_ [jquery-filedrop](http://github.com/weixiyen/jquery-filedrop), the plugin I modeled this after. Thanks weixiyen!
