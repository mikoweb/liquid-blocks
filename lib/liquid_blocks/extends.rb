module LiquidBlocks

  class Extends < ::Liquid::Block
    SYNTAX = /(#{Liquid::QuotedFragment}+)/

    attr_reader :template_name

    def initialize(tag_name, markup, tokens)
      if markup =~ SYNTAX
        @template_name = $1[1..-2]
      else
        raise Liquid::SyntaxError.new("Syntax Error in 'extends' - Valid syntax: extends [template]")
      end
      super
    end

    def parse(tokens)
      @body = Liquid::BlockBody.new
      parse_all(tokens)
    end

    def render(context)
      origin = populate_nodelist(self, context)
      @body.nodelist.clear
      origin.root.nodelist.each {|item| @body.nodelist << item}
      super
    end

    def nodelist
      @body.nodelist
    end

    def blank?
      false
    end

    # Load the template that is being extended by the current tag.
    #
    # @param template_name [String] the context to use when loading the template
    # @return [Liquid::Document] the parsed template
    def load_template(template_name)
      source = Liquid::Template.file_system.read_template_file(template_name)
      Liquid::Template.parse(source)
    end

    private

    def create_variable(token, parse_context)
      token.scan(Liquid::BlockBody::ContentOfVariable) do |content|
        markup = content.first
        return Liquid::Variable.new(markup, parse_context)
      end
      raise Liquid::SyntaxError.new(parse_context.locale.t("errors.syntax.variable_termination".freeze, token: token, tag_end: VariableEnd.inspect))
    end

    def parse_all(tokens)
      @body.nodelist.clear

      while token = tokens.shift
        case token
          when /^#{Liquid::TagStart}/
            if token =~ /^#{Liquid::TagStart}\s*(\w+)\s*(.*)?#{Liquid::TagEnd}$/
              # fetch the tag from registered blocks
              if tag = Liquid::Template.tags[$1]
                @body.nodelist << tag.parse($1, $2, tokens, @parse_context)
              else
                # this tag is not registered with the system
                # pass it to the current block for special handling or error reporting
                unknown_tag($1, $2, tokens)
              end
            else
              raise Liquid::SyntaxError, "Tag '#{token}' was not properly terminated with regexp: #{Liquid::TagEnd.inspect}"
            end
          when /^#{Liquid::VariableStart}/
            @body.nodelist << create_variable(token, @parse_context)
          when ''
            # pass
          else
            @body.nodelist << token
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
      parent = tag.load_template(@template_name)
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
          parent_block.nodelist.clear
          block.nodelist.each {|item| parent_block.nodelist << item}
        elsif extends
          parent_node.nodelist << block
        end
      end

      # Pass likely context variables on to parent templates
      included_templates = (context.registers[:cached_partials] || {}).keys
      included_templates.each do |included_template|
        if context.key?(included_template)
          context[tag.template_name] ||= context[included_template]
        end
      end

      parent
    end

  end

end
