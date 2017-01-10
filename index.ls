<- $(document).ready
plotd3 = {label: {}}
 
plotd3.label.placement = ->
  store = {}
  ret = {}

  collide = ->
    bbox = store.labels
    bbox.map -> it.collide = false
    store.nodes.map (d,i) -> d.label.box = d.anchor.node .getBBox!
    has = false
    for i from 0 til bbox.length
      for j from i + 1 til bbox.length
        [ni,nj] = [bbox[i].box, bbox[j].box]
        if !(nj.x > ni.x + ni.width or nj.x + nj.width < ni.x or
        nj.y > ni.y + ni.height or nj.y + nj.height < ni.y) =>
          bbox[j].collide = true
          bbox[j].collideCount = (bbox[j].collideCount or 0) + 1
          bbox[i].collide = true
          bbox[i].collideCount = (bbox[i].collideCount or 0) + 1
          has = true
    bbox.map -> if !it.collide => it.collideCount = 0
    has

  tick = ->
    alpha = store.force.alpha!
    if collide! =>
      for i from 0 til store.labels.length =>
        store.labels[i].x = store.anchors[i].x
        if store.labels[i].y > store.anchors[i].y => store.labels[i].y = store.anchors[i].y
      store.force.charge (d,i) -> if d.collide => -280 - 10 * d.collideCount else -60
      store.force.start!
      store.force.alpha alpha
    else if alpha < 0.01
      store.force.stop!
    store.tags.each (d,i) ->
      d.offset = {x: store.labels[i].x, y: store.labels[i].y}

  ret.nodes = (nodes) ->
    store.tags = nodes
    store.anchors = []
    nodes.each (d,i) -> store.anchors.push {x: d.x, y: d.y, fixed: true, node: @}
    store.labels = store.anchors.map -> {x: it.x, y: it.y}
    store.nodes = store.anchors.map (d,i) -> {anchor: store.anchors[i], label: store.labels[i]}
    store.pts = store.anchors ++ store.labels 
    store.links = store.anchors.map (d,i) -> {source: i, target: store.anchors.length + i}
    store.force = d3.layout.force!
      .nodes store.pts
      .links store.links
      .linkDistance 10
      .linkStrength 0.5
      .on \tick, tick
      .size [400, 300]
      .gravity 0
      .friction 0.6
    store.force.start!
  return ret

svg = d3.select \svg
w = svg.0.0.getBoundingClientRect!width
h = svg.0.0.getBoundingClientRect!height

data = d3.range(20).map (d,i) -> do
  value: Math.round(Math.random!*10) + 1
data.map (d,i) ->
  d <<< do
    x: i * 22 + 20
    y: 300 - d.value * 10
    width: 20
    height: d.value * 10

svg.selectAll \rect .data data .enter!append \rect .attr do
  x: -> it.x
  y: -> it.y
  width: -> it.width
  height: -> it.height
  fill: \#f99

lines = svg.selectAll \line .data data .enter!append \line

nodes = svg.selectAll \text .data data .enter!append \text
  .attr do
    x: -> it.x + it.width/2
    y: -> it.y
    "text-anchor": \middle
    fill: \#000
  .text -> parseInt(it.value * Math.random! * 1000)

plotd3.label.placement!nodes nodes
setInterval (->
  lines.attr do
    x1: -> it.x + it.width/2
    y1: -> it.y
    x2: -> it.offset.x + it.width/2
    y2: -> it.offset.y
    "stroke-width": 1
    stroke: \#000
  nodes.attr do
    x: -> it.offset.x + it.width/2
    y: -> it.offset.y
), 100
