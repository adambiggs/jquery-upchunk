Upchunk _- a modern file upload plugin for jQuery_
===========================

Features
-------------

- HTML5 drag n' drop capabilities
- HTML5 chunk support (for large files)
- Standard file upload window fallback option (soon to dynamically fallback to an HTML4-compatible version when appropriate)

Usage
-----

Values seen below are defaults, empty symbolizes an empty function.

```javascript

$('#dropzone').upchunk({
  url: '',                                          // the url the file will be sent to
  chunk: false,                                     // whether or not files will be sent to the server in chunks
  chunk_size: 1024,                                 // the size of each chunk
  fallback_id: '',                                  // an identifier of a standard file input field to optionally interface with the plugin
  file_param: 'file',                               // the name of the parameter the file will have when sent to the server
  name_param: 'file_name',                          // the name of the parameter the file name will have when sent to the server
  max_file_size: 0,                                 // the maximum size of each uploaded file, 0 for infinite
  queue_size: 2,                                    // the maximum amount of files to upload to the server at once
  data: {},                                         // additional parameters to be sent to the server
  drop: function(e){},                              // a function that will be executed when the files are dropped
  dragEnter: function(e){},                         // a function that will be executed when files are dragged over the dropzone
  dragLeave: function(e){},                         // a function that will be executed when dragged files leave the dropzone
  docEnter: function(e){},                          // a function that will be executed when dragged files enter the browser window
  docLeave: function(e){},                          // a function that will be executed when dragged files leave the browser window
  beforeEach: function(){},                         // a function that will be executed before each file begins uploading
  afterAll: function(){},                           // a function that will be executed after all files are finished uploading
  rename: function(s) {return s},                   // a function that will rename the file before being sent to the server
  error: function(err) { alert(err) },              // a function that responds to errors; err can be one of the following: ['BrowserNotSupported', 'FileTooLarge']
  uploadStarted: function(file, hash){},            // a function that is executed when an upload starts
  uploadFinished: function(file, hash, response){}, // a function that is executed when an upload finishes
  progressUpdated: function(file, hash, progress){} // a function that is executed each percentage update (soon to incorporate a refresh_rate parameter instead)
})

```

Contributions
-------------
[jquery-filedrop](http://github.com/weixiyen/jquery-filedrop), the plugin I modeled this after. Thanks weixiyen!