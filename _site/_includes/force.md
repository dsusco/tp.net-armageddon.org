<div>
## {{ include.force.name }} Forces

{::nomarkdown}
<div class="datasheet">{% for u in include.force.units %}{% unit u %}
{% include unit.html unit = unit %}
{% endunit %}{% endfor %}  </div>{% for sr in include.force.special_rules %}
{:/}

<div class="sr">{% specialrule sr %}
### {{ specialrule.name }}

{{ specialrule.content | markdownify }}
{% endspecialrule %}</div>{% endfor %}
</div>