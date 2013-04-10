require "yaconfig/version"

require 'symboltable'
require 'json'

module Yaconfig
  class Configuration < SymbolTable 

    # Legacy module to recieve constants
    attr_accessor :base_name, :verbose

    # Setup @data. Accept an optional hash of config.
    def initialize(data=nil, &block)
      # Base name of the program, minus .rb if any.
      @base_name = File::basename($0)
      @base_name = @base_name[0..-4] if @base_name =~ /\.rb$/

      # Off by default
      @verbose = false

      # List of loaded config files
      @configs = []

      # Install any passed data into the SymbolTable
      r = super(data)

      # Do a block style config, if any
      block.call(self) if block_given?

      # Return what super gave us.
      return r
    end

    # On the fly creation of sub containers.
    #
    # downside is it kills config.x.y #=> nil
    # so I have left this out until I can magically figure out I'm on the
    # left side of the expression.

    # def method_missing(method, *args, &block)
    #   rv = super
    #   if !rv
    #     store(method, {})
    #     super
    #   end
    # end

    # Use a block-style configure setup. 
    #
    # config.configure do |c|
    #   c.whatever = a_value
    # end
    def configure(&block)
        raise "No block given to configure." if !block_given?

        block.call(self)
    end

    # Search a list of files, and load any that exist. Provides
    # the object as 'config'
    def load_config(*args)
      args.flatten.each{ |f| load_config_file(f) }
    end

    # JSON support
    def configure_json(json_text)
      self.merge!(JSON.parse(json_text))
    end

    def to_json_pretty()
      JSON.pretty_generate(self)
    end

    def load_config_json(*args)
      args.flatten.each{ |f| 
        configure_json(File.new(f, 'r').read) if File.exists?(f) 
      }
    end

    private # ----------------------------------

    # expand path
    def expand_path(file)
      file.gsub!(/\%basedir\%/, File.dirname(File.expand_path($0)))
      file.gsub!(/\%basename\%/, @base_name)
      File.expand_path(file)
    end

    # Used by load_config
    def load_config_file(filename)
      config = self

      filename = expand_path(filename)

      return if @configs.include?(filename) 

      if File.exists?(filename)
        puts "Loading config from: #{filename}" if @verbose
        eval File.new(filename, "r").read
        @configs << filename
      else
        puts "Config file does not exist: #{filename}" if @verbose && @verbose >= 2
      end
    end

  end
end
