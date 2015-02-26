module LiquidBlocks

  class Extends < ::Liquid::Block
    Syntax = /(#{Liquid::QuotedFragment}+)/

    attr_reader :template_name

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @template_name = $1[1..-2]
      else
        raise Liquid::SyntaxError.new("Syntax Error in 'extends' - Valid syntax: extends [template]")
      end
      super
    end

    def parse(tokens)
      parse_all(tokens)
    end

    def render(context)
      origin = populate_nodelist(self, context)
      origin.render(context)
    end

    # Load the template that is being extended by the current tag.
    #
    # @param context [Liquid::Context] the context to use when loading the template
    # @return [Liquid::Document] the parsed template
    def load_template(context)
      source = Liquid::Template.file_system.read_template_file(@template_name, context)
      Liquid::Template.parse(source)
    end

    private

    def parse_all(tokens)
      @nodelist ||= []
      @nodelist.clear

      while token = tokens.shift
        case token
        when /^#{Liquid::TagStart}/
          if token =~ /^#{Liquid::TagStart}\s*(\w+)\s*(.*)?#{Liquid::TagEnd}$/
            # fetch the tag from registered blocks
            if tag = Liquid::Template.tags[$1]
              @nodelist << tag.new($1, $2, tokens)
            else
              # this tag is not registered with the system
              # pass it to the current block for special handling or error reporting
              unknown_tag($1, $2, tokens)
            end
          else
            raise Liquid::SyntaxError, "Tag '#{token}' was not properly terminated with regexp: #{Liquid::TagEnd.inspect}"
          end
        when /^#{Liquid::VariableStart}/
          @nodelist << create_variable(token)
        when ''
          # pass
        else
          @nodelist << token
        end
      end
    end

    # Find all +block+ tags defined as children of the given node.
    #
    # The returned hash will have keys that are the names of the declared
    # blocks, with values of +LiquidBlocks::Block+ instances.
    #
    # @param node [Liquid::Tag] a possible +block+ tag
    # @param blocks [Hash] a set of existing blocks to build on
    # @return [Hash] all blocks provided by the given node
    def find_blocks(node, blocks={})
      if node.respond_to?(:nodelist) && !node.nodelist.nil?
        node.nodelist.inject(blocks) do |b, node|
          if node.is_a?(LiquidBlocks::Block)
            b[node.name] = node
          end
          find_blocks(node, b)

          b
        end
      end

      blocks
    end

    # Get the first +extends+ tag in the given template, falling back to
    # +nil+ if the template does not contain an +extends+ tag.
    #
    # @param template [Liquid::Document] a template in which to search for an +extends+ tag
    # @return [LiquidBlocks::Extends] the first +extends+ tag, or +nil+
    def get_extends_tag_for_template(template)
      template.root.nodelist.select { |node| node.is_a?(Extends) }.first
    end

    # Populate the nodelist for the highest-level template being extended with
    # the contents of its child +block+ tags.
    #
    # @param tag [Liquid::Tag] an instance of an +extends+ tag
    # @param context [Liquid::Context] the context to use when loading the template
    # @return [Liquid::Document] the top-level template with a modified nodelist
    def populate_nodelist(tag, context)

      # Get the template being extended by the tag and get an appropriate root
      # node for it based on whether or not it extends another template
      parent = tag.load_template(context)
      parent_blocks = find_blocks(parent.root)
      extends = get_extends_tag_for_template(parent)
      parent_node = extends || parent.root

      # Examine every block in the current tag, replacing a matching block in
      # its parent or adding it to its parent's nodelist, provided that the
      # parent is not the top-level template
      find_blocks(tag).each do |name, block|
        parent_block = parent_blocks[name]
        if parent_block
          parent_block.parent = block.parent
          parent_block.add_parent(parent_block.nodelist)
          parent_block.nodelist = block.nodelist
        elsif extends
          parent_node.nodelist << block
        end
      end

      # Pass likely context variables on to parent templates
      included_templates = (context.registers[:cached_partials] || {}).keys
      included_templates.each do |included_template|
        if context.has_key?(included_template)
          context[tag.template_name] ||= context[included_template]
        end
      end

      # If the current template extends another, walk up the inheritance chain
      if extends
        populate_nodelist(extends, context)
      end

      parent
    end

  end

end
