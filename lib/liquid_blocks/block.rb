module LiquidBlocks

  class BlockDrop < ::Liquid::Drop
    def initialize(block)
      @block = block
    end

    def super
      @block.call_super(@context)
    end
  end

  class Block < ::Liquid::Block
    SYNTAX = /([\w!]+)/

    attr_accessor :parent
    attr_reader :name

    def initialize(tag_name, markup, tokens)
      @parent = nil

      if markup =~ SYNTAX
        @name = $1
      else
        raise Liquid::SyntaxError.new("Syntax Error in 'block' - Valid syntax: block [name]")
      end

      super if tokens
    end

    def render(context)
      context.stack do
        context['block'] = BlockDrop.new(self)

        super
      end
    end

    def add_parent(nodelist)
      if @parent != nil
        @parent.add_parent(nodelist)
      else
        @parent = Block.parse(@tag_name, @name, Liquid::Tokenizer.new(@name + '{% end' + @tag_name + '%}'), @parse_context)
        @parent.nodelist.clear
        nodelist.each {|item| @parent.nodelist << item}
      end
    end

    def blank?
      false
    end

    def call_super(context)
      if @parent
        @parent.render(context)
      else
        ''
      end
    end

  end

end
