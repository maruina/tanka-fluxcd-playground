{
  // +:: is important (we don't want to override the
  // _config object, just add to it)
  _config+:: {
    // define a namespace for this library
    eks: {},
  },

  // again, make sure to use +::
  _images+:: {},
}
