## Rails 8.0.0.alpha9 (September 25, 2024) ##

*   No changes.


## Rails 8.0.0.alpha8 (September 18, 2024) ##

*   No changes.


## Rails 8.0.0.alpha7 (September 18, 2024) ##

*   No changes.


## Rails 8.0.0.alpha6 (September 18, 2024) ##

*   No changes.


## Rails 8.0.0.alpha5 (September 18, 2024) ##

*   No changes.


## Rails 8.0.0.alpha5 (September 18, 2024) ##

*   No changes.


## Rails 8.0.0.alpha4 (September 18, 2024) ##

*   No changes.


## Rails 8.0.0.alpha4 (September 18, 2024) ##

*   No changes.


## Rails 8.0.0.alpha4 (September 18, 2024) ##

*   No changes.


## Rails 8.0.0.alpha4 (September 18, 2024) ##

*   No changes.


## Rails 8.0.0.alpha4 (September 18, 2024) ##

*   No changes.


## Rails 8.0.0.alpha4 (September 18, 2024) ##

*   Remove `sucker_punch` as an adapter option [since author himself recommends using AJ's own AsyncAdapter](https://github.com/brandonhilkert/sucker_punch?tab=readme-ov-file#faq).
    If you're using this adapter, change to `adapter: async` for the same functionality.

    *Dino Maric*

*   Use `RAILS_MAX_THREADS` in `ActiveJob::AsyncAdapter`. If it is not set, use 5 as default.

    *heka1024*

Please check [7-2-stable](https://github.com/rails/rails/blob/7-2-stable/activejob/CHANGELOG.md) for previous changes.
