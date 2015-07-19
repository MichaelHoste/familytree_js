class @Constants

  @width          = 90
  @height         = 50
  @padding        = 20
  @margin         = 60
  @fontSize       = 15
  @lineWidth      = 2
  @verticalMargin = @margin * 1.5

  # Real effective with on the screen (but calculations are not based on it because the line width is never really big)
  @effectiveWidth = Constants.width + Constants.lineWidth
