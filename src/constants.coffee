class @Constants

  @width          = 90
  @height         = 50
  @padding        = 20
  @margin         = 60
  @fontSize       = 15
  @lineWidth      = 2
  @verticalMargin = @margin * 1.5

  @t: (enText, frText) ->
    if @locale == undefined || @locale == 'en'
      enText
    else
      frText
