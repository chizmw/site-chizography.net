### Recent Post

### Recent Post

<h2>Recent Post</h2>
<ul class="post-list">
    <li class="clearboth">
    {%- assign date_format = site.minima.date_format | default: "%b %-d, %Y" -%}
    <h3>
        <a class="post-link" href="{{ post.url | relative_url }}">
        {{ post.title | escape }}
        </a>
    </h3>
    <!-- Your post's summary goes here -->
    <article>{{ post.excerpt }}</article>
        <a class="" href="{{ post.url | relative_url }}">
        [Read More]
        </a>
    </li>
</ul>
    <br class="clearboth" />
