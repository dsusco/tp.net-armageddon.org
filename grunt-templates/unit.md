---
name: "<%= name %>"
type: "<%= type %>"
speed: "<%= speed %>"
armour: "<%= armour %>"
cc: "<%= cc %>"
ff: "<%= ff %>"<% if (special_rules !== null) { %>
special_rules:<% special_rules.forEach(function (sr) { %>
  - "<%= sr %>"<% }) %><% } %><% if (notes !== '') { %>
notes:
  |
    <%= notes %><% } %><% if (weapons !== null && weapons.length) { %>
weapons:<% weapons.forEach(function (w) { %>
  -
    id: "<%= w.id %>"<% if (w.multiplier !== '1') { %>
    multiplier: "<%= w.multiplier %>"<% } %><% if (w.arc !== '') { %>
    arc: "<%= w.arc %>"<% } %><% }) %><% } %>
---