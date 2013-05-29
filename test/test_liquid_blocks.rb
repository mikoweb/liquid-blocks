require 'test/unit'
require 'liquid_blocks'

class TestFileSystem
  def read_template_file(path, context)
    if path == 'simple'
      'test'
    elsif path == 'complex'
      %{
        beginning

        {% block thing %}
        rarrgh
        {% endblock %}

        {% block another %}
        bum
        {% endblock %}

      end
      }
    elsif path == 'nested'
      %{
        {% extends 'complex' %}

        {% block thing %}
        from nested
        {% endblock %}

        {% block another %}
        from nested (another)
        {% endblock %}
      }
    elsif path == 'nested_more'
      %{
        {% extends 'complex' %}

        {% block thing %}
        thing
        {% endblock %}
      }
    elsif path == 'similar'
      %{
        {% block aralia %}
        aralia
        {% endblock %}

        {% block azalea %}
        azalea
        {% endblock %}
      }
    elsif path == 'deep'
      %{
        {% block one %}
          one
          {% block two %}
            two
            {% block three %}three{% endblock %}
            {% block four %}four{% endblock %}
          {% endblock %}
        {% endblock %}
      }
    elsif path == 'nested_deep'
      %{
        {% extends 'deep' %}
      }
    elsif path == 'ruby'
      %{
        {% block test %}{% endblock %}
        {% block test! %}{% endblock %}
      }
    end
  end
end

Liquid::Template.file_system = TestFileSystem.new

class LiquidBlocksTest < Test::Unit::TestCase
  def test_output_the_contents_of_the_extended_template
    template = Liquid::Template.parse %{
      {% extends 'simple' %}

      {% block thing %}
      yeah
      {% endblock %}
    }

    assert_match /test/, template.render
  end

  def test_render_original_content_of_block_if_no_child_block_given
    template = Liquid::Template.parse %{
      {% extends 'complex' %}
    }

    assert_match /rarrgh/, template.render
    assert_match /bum/, template.render
  end

  def test_render_child_content_of_block_if_child_block_given
    template = Liquid::Template.parse %{
      {% extends 'complex' %}

      {% block thing %}
      booyeah
      {% endblock %}
    }

    assert_match /booyeah/, template.render
    assert_match /bum/, template.render
  end

  def test_render_child_content_of_blocks_if_multiple_child_blocks_given
    template = Liquid::Template.parse %{
      {% extends 'complex' %}

      {% block thing %}
      booyeah
      {% endblock %}

      {% block another %}
      blurb
      {% endblock %}
    }

    assert_match /booyeah/, template.render
    assert_match /blurb/, template.render
  end

  def test_remember_context_of_child_template
    template = Liquid::Template.parse %{
      {% extends 'complex' %}

      {% block thing %}
      booyeah
      {% endblock %}

      {% block another %}
      {{ a }}
      {% endblock %}
    }

    res = template.render 'a' => 1234

    assert_match /booyeah/, res
    assert_match /1234/, res
  end

  def test_work_with_nested_templates
    template = Liquid::Template.parse %{
      {% extends 'nested' %}

      {% block thing %}
      booyeah
      {% endblock %}
    }

    res = template.render 'a' => 1234

    assert_match /booyeah/, res
    assert_match /from nested/, res
  end

  def test_work_with_nested_templates_if_middle_template_skips_a_block
    template = Liquid::Template.parse %{
      {% extends 'nested_more' %}

      {% block another %}
      win
      {% endblock %}
    }

    res = template.render

    assert_match /win/, res
    assert_no_match /bum/, res
  end

  def test_render_parent_for_block_super
    template = Liquid::Template.parse %{
      {% extends 'complex' %}

      {% block thing %}
      {{ block.super }}
      {% endblock %}
    }

    res = template.render 'a' => 1234

    assert_match /rarrgh/, res
  end

  def test_render_separate_block_content_for_blocks_with_identical_first_or_last_letters
    template = Liquid::Template.parse %{
      {% extends 'similar' %}

      {% block aralia %}
      spikenard
      {% endblock %}

      {% block azalea %}
      tsutsuji
      {% endblock %}
    }

    res = template.render

    assert_match /spikenard/, res
    assert_match /tsutsuji/, res
  end

  def test_render_deep_blocks
    template = Liquid::Template.parse %{
      {% extends 'deep' %}
    }

    res = template.render

    assert_match /three/, res
  end

  def test_render_deep_blocks_override_inner_blocks
    template = Liquid::Template.parse %{
      {% extends 'deep' %}

      {% block two %}extra {{ block.super }}{% endblock %}
      {% block three %}override{% endblock %}
    }

    res = template.render

    assert_match /one/, res
    assert_match /two/, res
    assert_match /extra/, res
    assert_match /override/, res
    assert_no_match /three/, res
  end

  def test_render_deep_blocks_hide_child_blocks_if_parent_empty
    template = Liquid::Template.parse %{
      {% extends 'nested_deep' %}

      {% block two %}{% endblock %}
      {% block three %}hidden{% endblock %}
    }

    res = template.render

    assert_no_match /two/, res
    assert_no_match /hidden/, res
    assert_no_match /four/, res
  end

  def test_render_blocks_ruby_name
    template = Liquid::Template.parse %{
      {% extends 'ruby' %}

      {% block test %}quiet{% endblock %}
      {% block test! %}loud{% endblock %}
    }

    res = template.render

    assert_match /quiet/, res
    assert_match /loud/, res
  end
end
