require 'liquid'
require 'liquid_blocks'
require 'sinatra'

Liquid::Template.file_system = Liquid::LocalFileSystem.new(settings.views)

get '/' do
  liquid :index, :locals => { :hi => 'Hi!' }
end

get '/:hi' do
  liquid :index, :locals => { :hi => params[:hi] }
end
