*   Add support for strong parameter to deal with nested arrays

    Strong parameters doesn't support nested arrays,
    take as example: `[[{ name: 'Leonardo', age: 26 }]]`.

    This is fixed adding a method that is called when object is an array, and recursively returns allowed values.


    Fixes #23640.

    *Leonardo Siqueira*

*   Add method `dig` to `session`.

    *claudiob*, *Takumi Shotoku*

*   Controller level `force_ssl` has been deprecated in favor of
    `config.force_ssl`.

    *Derek Prior*

*   Rails 6 requires Ruby 2.4.1 or newer.

    *Jeremy Daer*


Please check [5-2-stable](https://github.com/rails/rails/blob/5-2-stable/actionpack/CHANGELOG.md) for previous changes.
