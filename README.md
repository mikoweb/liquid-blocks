# Liquid Blocks

This gem adds Django-like `block` and `extends` tags to the
[Liquid](http://www.liquidmarkup.org/) templating language.

## Usage

Add the following to your `Gemfile`

    gem 'liquid4-blocks', '~> 0.7.0'

And the following to your code

    require 'liquid_blocks'

This allows you to have `hello.liquid`

    {% extends 'layout' %}

    {% block middle %}hello{% endblock %}

Which extends `_layout.liquid`

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
