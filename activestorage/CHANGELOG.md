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

*   Deprecate `ActiveStorage::Service::AzureStorageService`.

    *zzak*

*   Improve `ActiveStorage::Filename#sanitized` method to handle special characters more effectively.
    Replace the characters `"*?<>` with `-` if they exist in the Filename to match the Filename convention of Win OS.

    *Luong Viet Dung(Martin)*

*   Improve InvariableError, UnpreviewableError and UnrepresentableError message.

    Include Blob ID and content_type in the messages.

    *Petrik de Heus*

*   Mark proxied files as `immutable` in their Cache-Control header

    *Nate Matykiewicz*


Please check [7-2-stable](https://github.com/rails/rails/blob/7-2-stable/activestorage/CHANGELOG.md) for previous changes.
