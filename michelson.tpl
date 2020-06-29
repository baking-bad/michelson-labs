{%- extends 'markdown.tpl' -%}

{% block stream %}
<div class="{{ output.name }}">
    <pre><span class="stream-name">{{ output.name }}</span><br/>{{ output.text | e }}</pre>
</div>
{% endblock stream %}