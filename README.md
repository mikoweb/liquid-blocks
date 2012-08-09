# Liquid Blocks [![Build Status](https://secure.travis-ci.org/silas/liquid-blocks.png)](http://travis-ci.org/silas/liquid-blocks)

This gem adds Django-like `block` and `extends` tags to the
[Liquid](http://www.liquidmarkup.org/) templating language.

## Usage

Add the following to your `Gemfile`

    gem 'liquid-blocks'

And the following to your code

    require 'liquid_blocks'

This allows you to have template `hello.liquid`

    {% extends 'layout' %}

    {% block middle %}hello{% endblock %}

Which extends template `_layout.liquid`

    top

    {% block middle %}middle{% endblock %}

    bottom

Which renders into

    top

    hello

    bottom

## License

This work is licensed under the MIT License (see the LICENSE file).

Copyright &copy; 2009 Dan Webb
