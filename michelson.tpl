{%- extends 'markdown.tpl' -%}

{% block stream %}
<div class="{{ output.name }}">
    <pre><span class="stream-name">{{ output.name }}</span><br/>{{ output.text | e }}</pre>
</div>
{% endblock stream %}

{% block data_html %}
<div class="embedded-html">
{{ output.data['text/html'] }}
</div>
{% endblock data_html %}