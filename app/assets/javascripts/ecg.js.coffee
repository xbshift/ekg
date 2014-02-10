class ECGPattern
  constructor: ->
    @numbers = d3.range(5).map(d3.random.normal(0, .2))
  numbers: ->
    @numbers
  next_number: ->
    num = @numbers[0]
    @numbers.shift()
    num

class ECGGraph
  constructor: (selector) ->
    @num_width = 40
    @data = []
    @margin = {top: 20, right: 20, bottom: 20, left: 40}
    @width = 960 - @margin.left - @margin.right
    @height = 500 - @margin.top - @margin.bottom

    @x = d3.scale.linear().domain([0, @num_width - 1]).range([0, @width])

    @y = d3.scale.linear().domain([-1, 1]).range([@height, 0])

    @line = d3.svg.line().interpolate('cardinal')
      .x((d, i) =>
        return @x(i))
      .y((d, i) =>
        return @y(d))

    @svg = d3.select(selector).append("svg")
      .attr("width", 960)
      .attr("height", 500)
      .append("g")
      .attr("transform", "translate(" + @margin.left + "," + @margin.top + ")")

    @draw_guides()

    @path = @svg.append("g")
      .attr("clip-path", "url(#clip)")
      .append("path")
      .datum(@data)
      .attr("class", "line")
      .attr("d", @line)
  draw_guides: ->
    @svg.append("defs").append("clipPath")
      .attr("id", "clip")
      .append("rect")
      .attr("width", @width)
      .attr("height", @height)

    @svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + @y(0) + ")")
      .call(d3.svg.axis().scale(@x).orient("bottom"))

    @svg.append("g")
      .attr("class", "y axis")
      .call(d3.svg.axis().scale(@y).orient("left"))
  draw_pattern: (pattern) ->
    window.pattern = pattern
    number = pattern.next_number()

    if number || number == 0
      @data.push(number)
      @path.attr("d", @line)
        .attr("transform", null)
        .transition()
        .each('end', =>
          @draw_pattern(pattern)
        )
      if @data.length > 40
        @path.attr("transform", "translate(" + x(-1) + ",0)")
        @data.shift()

jQuery ->
  pattern = new ECGPattern
  graph = new ECGGraph('body')
  graph.draw_pattern(pattern)
