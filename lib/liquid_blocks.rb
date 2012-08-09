require 'liquid'

module LiquidBlocks
  autoload :Extends, 'liquid_blocks/extends'
  autoload :Block, 'liquid_blocks/block'
end

Liquid::Template.register_tag(:extends, LiquidBlocks::Extends)
Liquid::Template.register_tag(:block, LiquidBlocks::Block)
