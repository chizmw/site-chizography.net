<div class="read-estimate">
    {% assign words = page.content | strip_html | number_of_words %}
    {{ words | divided_by: 180 | plus: 1 }} minute read
</div>
