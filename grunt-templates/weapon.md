---
name: "<%= name %>"
modes:<% modes.forEach(function (m) { %>
  -<% if (m.boolean !== '') { %>
    boolean: "<%= m.boolean %>"<% } %>
    range: "<%= m.range %>"
    firepower: "<%= m.firepower %>"<% if (m.special_rules !== null) { %>
    special_rules:<% m.special_rules.forEach(function (sr) { %>
      - "<%= sr %>"<% }) %><% } %><% }) %>
---