fileSeparator = "/"

normalizePath = (path) ->
  path.replace(/\/+/g, fileSeparator) # /// -> /
  .replace(/\/[^/]*\/\.\./g, "") # /base/something/.. -> /base
  .replace(/\/\.\//g, fileSeparator) # /base/. -> /base

# NOTE: Allows paths like '../..' to go above the base path
absolutizePath = (base, relativePath) ->
  normalizePath "/#{base}/#{relativePath}"

module.exports =
  absolutizePath: absolutizePath
