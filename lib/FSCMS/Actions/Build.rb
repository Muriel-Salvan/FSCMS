#--
# Copyright (c) 2009-2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

require 'fileutils'

module FSCMS

  module Actions
  
    class Build

      # Get the specific options parser
      #
      # Return:
      # * _OptionsParser_: The options parser
      def getOptionsParser
        rOptions = OptionParser.new

        # The list of targets, as specified as options
        # list< String >
        @LstTargets = []
        @ForceBuild = false

        # Initialize properties that will be set by the options parser
        rOptions.on( '--target <TargetName>', String,
          '<TargetName>: Name of target to build (ex.: TrackMusics/RR126/0.1.20101102/WAV_192kHz_24bits)',
          'Set a Target to build (can be specified several times).') do |iArg|
          @LstTargets << iArg
        end
        rOptions.on( '--force',
          'Force building this target even if it was already built.') do
          @ForceBuild = true
        end

        return rOptions
      end

      # Execute the action
      # This method can use the following instance variables to access common properties:
      # * *@Proxy*: The proxy of SimpleCSM
      def execute
        # Compute the list of deliverables
        # list<Deliverable>
        lLstDeliverables = []
        @LstTargets.each do |iTarget|
          # Get the corresponding deliverables
          lLstDeliverables += @Proxy.getDeliverableTargets(iTarget)
        end
        # The list of deliverables built
        # map< Deliverable, nil >
        @DeliverablesBuilt = {}
        if (!@ForceBuild)
          lLstDeliverables.uniq.each do |ioDeliverable|
            if (ioDeliverable.AlreadyBuilt)
              @DeliverablesBuilt[ioDeliverable] = nil
            end
          end
        end
        # Build each deliverable
        lLstDeliverables.uniq.each do |ioDeliverable|
          buildDeliverableAndDependencies(ioDeliverable)
        end
      end

      private

      # Build a given deliverable.
      # This method will also build its dependencies.
      #
      # Parameters:
      # * *ioDeliverable* (_Deliverable_): Deliverable to build
      def buildDeliverableAndDependencies(ioDeliverable)
        # First consider its dependencies
        lDependencies = {}
        @Proxy.getDeliverableDependencies(ioDeliverable, lDependencies)
        lDependencies.each do |ioDepDeliverable, iNil|
          logInfo "Build dependency #{ioDepDeliverable.RealDir}"
          buildDeliverable(ioDepDeliverable)
        end
        # The build it
        buildDeliverable(ioDeliverable)
      end

      # Build a given deliverable.
      # Prerequisite: its dependencies have been built.
      #
      # Parameters:
      # * *ioDeliverable* (_Deliverable_): Deliverable to build
      def buildDeliverable(ioDeliverable)
        if (@DeliverablesBuilt.has_key?(ioDeliverable))
          logInfo "Deliverable #{ioDeliverable.RealDir} is already built."
        else
          lProcessInfo, lProcessParams = ioDeliverable.getProcessInfo
          if (lProcessInfo == nil)
            # No process to build it.
            # Tell the user it has to do it by hand.
            logMsg "No process defined to build deliverable #{ioDeliverable.RealDir}. Build it manually and press Enter to continue."
            $stdin.gets
            @DeliverablesBuilt[ioDeliverable] = nil
          else
            # Execute the building process
            logInfo "Build deliverable #{ioDeliverable.RealDir} ..."
            lAliases = ioDeliverable.Context.Aliases.merge(@Proxy.params2aliases(lProcessParams))
            lProcessDir = lProcessInfo[:Dir] || ioDeliverable.RealDir
            lRealProcessDir = @Proxy.replaceAliases(lProcessDir, lAliases)
            lCmd = lProcessInfo[:Cmd]
            if (lCmd == nil)
              raise RuntimeError.new("Process #{lSymProcess.to_s} has no :Cmd attribute defined.")
            end
            lRealCmd = @Proxy.replaceAliases(lCmd, lAliases)
            # Create the destination dir
            FileUtils::mkdir_p(ioDeliverable.RealDir)
            # Execute the process
            changeDir(lRealProcessDir) do
              logDebug "Execute command \"#{lRealCmd}\" from \"#{lRealProcessDir}\"..."
              lSuccess = system(lRealCmd)
              lErrorCode = $?
              if (lSuccess != true)
                raise RuntimeError.new("Error while executing \"#{lRealCmd}\" from \"#{lRealProcessDir}\": #{lErrorCode}")
              end
              logDebug "Command \"#{lRealCmd}\" from \"#{lRealProcessDir}\" completed."
            end
            @DeliverablesBuilt[ioDeliverable] = nil
          end
        end
      end
      
    end
    
  end
  
end
