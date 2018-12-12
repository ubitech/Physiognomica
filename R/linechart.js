   // Add X axis 
    var x = d3.scaleLinear()
       .domain( [options[2], options[3]])
      .range([ 0, width ]);
      
    svg.append("g")
      .call(d3.axisBottom(x));
      
    svg.append("text")
    .attr("class", "x label")
    .attr("text-anchor", "end")
    .attr("x", width)
    .attr("y", height - 30)
    .style("text-anchor", "end")
    .text(options[4]);
      

    // Add Y axis
    var y = d3.scaleLinear()
      .domain( [options[0], options[1]])
      //.domain([0, d3.max(data)])
      .range([ height-30, 0 ]);
    svg.append("g")
      .call(d3.axisRight(y))
      .append("text")
      .attr("fill", "#000")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", "1.71em")
      .attr("text-anchor", "end")
       .text(options[5]);
      

    // Add the points
    svg
      .append("g")
      .selectAll("dot")
      .data(data)
      .enter()
      .append("circle")
        .attr("cx", function(d) { return x(d[options[4]]) } )
        .attr("cy", function(d) { return y(d[options[5]]) } )
        .attr("r", 3)
        .attr("fill", "#69b3a2")
        
 var   text = svg.append('text')
 
 
 
text.append("tspan")
              .text(options[6])
              .call(wrap)
              //.attr('x', 50)
              .attr('y', height)
              //.attr('fill', 'black');


function wrap(text, width) {
  text.each(function() {
    var text = d3.select(this),
        words = text.text().split(/\s+/).reverse(),
        word,
        line = [],
        lineNumber = 0,
        lineHeight = 1.1, // ems
        y = text.attr("y"),
        dy = parseFloat(text.attr("dy")),
        tspan = text.text(null).append("tspan").attr("x", 0).attr("y", y).attr("dy", dy + "em");
    while (word = words.pop()) {
      line.push(word);
      tspan.text(line.join(" "));
      if (tspan.node().getComputedTextLength() > width) {
        line.pop();
        tspan.text(line.join(" "));
        line = [word];
        tspan = text.append("tspan").attr("x", 0).attr("y", y).attr("dy", ++lineNumber * lineHeight + dy + "em").text(word);
      }
    }
  });
}
        

        
        

