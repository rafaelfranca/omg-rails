*   Deprecate `ActionView::Layouts#action_has_layout?` and `ActionView::Layouts#action_has_layout=`.
    Use `:only` or `:except` when configuring with `Controller.layout` or pass `layout: false` to `#render`.

    *Nick Sutterer*

Please check [5-0-stable](https://github.com/rails/rails/blob/5-0-stable/actionview/CHANGELOG.md) for previous changes.
