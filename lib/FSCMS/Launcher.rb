#--
# Copyright (c) 2009-2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'optparse'
require 'date'
require 'rUtilAnts/Misc'
RUtilAnts::Misc::initializeMisc
require 'FSCMS/Proxy'
require 'FSCMS/Database'

# getbyte compatibility for Ruby 1.8
if (RUBY_VERSION < '1.9')
  class String
    def getbyte(iIdx)
      return self[iIdx]
    end
  end
end

module FSCMS

  class Launcher

    # Constructor
    def initialize
      # Options set by the command line parser
      @DisplayHelp = false
      @Debug = false
      @ActionName = nil
      parsePlugins

      # The command line parser
      @Options = OptionParser.new
      @Options.banner = 'FSCMS.rb [--help] [--debug] <ActionName> -- <ActionOptions>'
      @Options.on( '--help',
        'Display help') do
        @DisplayHelp = true
      end
      @Options.on( '--debug',
        'Activate debug logs') do
        @Debug = true
      end
    end

    # Execute command line arguments
    #
    # Parameters:
    # * *iArgs* (<em>list<String></em>): Command line arguments
    # Return:
    # * _Integer_: The error code to return to the terminal
    def execute(iArgs)
      rResult = 0

      lBeginTime = DateTime.now
      lError = nil
      lActionArgs = nil
      begin
        # Split the arguments
        lMainArgs, lActionArgs = splitParameters(iArgs)
        lRemainingArgs = @Options.parse(lMainArgs)
        if (lRemainingArgs.size == 1)
          @ActionName = lRemainingArgs[0]
        elsif (!@DisplayHelp)
          lError = RuntimeError.new("Unknown arguments: #{lRemainingArgs.join(' ')}. Use --help for usage.")
        end
      rescue Exception
        lError = $!
      end
      if (lError == nil)
        if (@DisplayHelp)
          puts @Options
        else
          if (@Debug)
            activateLogDebug(true)
          end
          # Access the Action
          accessPlugin('Actions', @ActionName) do |ioActionPlugin|
            lPluginOptionsParser = ioActionPlugin.getOptionsParser
            begin
              lRemainingArgs = lPluginOptionsParser.parse(lActionArgs)
              if (!lRemainingArgs.empty?)
                lError = RuntimeError.new("Unknown arguments: #{lRemainingArgs.join(' ')}.")
              end
            rescue Exception
              lError = $!
            end
            if (lError == nil)
              lRootDir = File.expand_path(Dir.getwd)
              ioActionPlugin.instance_variable_set(:@Proxy, Proxy.new(Database.new(lRootDir), lRootDir))
              ioActionPlugin.execute
            end
          end
        end
      end

      if (lError != nil)
        logErr "Error encountered: #{lError}"
        rResult = 1
      end
      logInfo "Elapsed milliseconds: #{((DateTime.now-lBeginTime)*86400000).to_i}"

      return rResult
    end

    private
    
    # Parse plugins
    def parsePlugins
      lLibDir = File.expand_path(File.dirname(__FILE__))
      require 'rUtilAnts/Plugins'
      RUtilAnts::Plugins::initializePlugins
      parsePluginsFromDir('Actions', "#{lLibDir}/Actions", 'FSCMS::Actions')
    end

    # Split parameters, before and after the first -- encountered
    #
    # Parameters:
    # * *iParameters* (<em>list<String></em>): The parameters
    # Return:
    # * <em>list<String></em>: The first part
    # * <em>list<String></em>: The second part
    def splitParameters(iParameters)
      rFirstPart = iParameters
      rSecondPart = []

      lIdxSeparator = iParameters.index('--')
      if (lIdxSeparator != nil)
        if (lIdxSeparator == 0)
          rFirstPart = []
        else
          rFirstPart = iParameters[0..lIdxSeparator-1]
        end
        if (lIdxSeparator == iParameters.size-1)
          rSecondPart = []
        else
          rSecondPart = iParameters[lIdxSeparator+1..-1]
        end
      end

      return rFirstPart, rSecondPart
    end

  end

end
