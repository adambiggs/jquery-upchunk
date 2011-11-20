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
    property: 'value'

  class Plugin
    constructor: (@element, options) ->
      @options = $.extend {}, defaults, options

      @_defaults = defaults
      @_name = pluginName

      @init()

    init: ->

  # A really lightweight plugin wrapper around the constructor,
  # preventing against multiple instantiations
  $.fn[pluginName] = (options) ->
    this.each ->
      if !$.data(this, "plugin_#{pluginName}")
        $.data(this, "plugin_#{pluginName}", new Plugin(this, options))
)(jQuery, window, document)
