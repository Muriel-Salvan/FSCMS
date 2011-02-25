#--
# Copyright (c) 2009-2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module FSCMS

  module Actions
  
    class ListFiles

      # Get the specific options parser
      #
      # Return:
      # * _OptionsParser_: The options parser
      def getOptionsParser
        rOptions = OptionParser.new

        # The list of targets, as specified as options
        # list< String >
        @LstTargets = []
        @OutputFileName = nil

        # Initialize properties that will be set by the options parser
        rOptions.on( '--target <TargetName>', String,
          '<TargetName>: Name of target to gather files from (ex.: TrackMusics/RR126/0.1.20101102/WAV_192kHz_24bits)',
          'Specify a Target to get files from (can be specified several times).') do |iArg|
          @LstTargets << iArg
        end
        rOptions.on( '--outputfile <FileName>', String,
          '<FileName>: Name of a file name to be used to write the list of files.',
          'Specify an output file to be written with the files list (optional).') do |iArg|
          @OutputFileName = iArg
        end

        return rOptions
      end

      # Execute the action
      # This method can use the following instance variables to access common properties:
      # * *@Proxy*: The proxy of SimpleCSM
      def execute
        # List of files, per deliverable
        lLstFiles = {}
        @Proxy.foreachDeliverable(@LstTargets) do |iDeliverable|
          # The list of source files
          # list< String >
          @LstSrcFiles = []
          # The list of deliverable files that are issued from non-automated processes
          # list< String >
          @LstManualDeliverableFiles = []
          # The list of deliverables that are needed as manual processes, but are not built now
          # list< String >
          @LstManualMissingDeliverables = []
          @Proxy.visitDeliverable(iDeliverable, true) do |iVisitedDeliverable|
            listDeliverable(iVisitedDeliverable)
          end
          lLstFiles[iDeliverable] = [
            @LstSrcFiles.uniq.sort,
            @LstManualDeliverableFiles.uniq.sort,
            @LstManualMissingDeliverables.uniq.sort
          ]
        end
        # Display and store
        lLstFiles.each do |iDeliverable, iFilesInfo|
          iLstSrcFiles, iLstManualDeliverableFiles, iLstManualMissingDeliverables = iFilesInfo
          logMsg "== Deliverable #{iDeliverable.ID}
=== Critical source files:
  * #{iLstSrcFiles.join("\n  * ")}
=== Manual deliverable files:
  * #{iLstManualDeliverableFiles.join("\n  * ")}
=== Manual deliverables missing files now:
  * #{iLstManualMissingDeliverables.join("\n  * ")}

"
        end
        if (@OutputFileName != nil)
          lOutputFiles = {}
          lLstFiles.each do |iDeliverable, iFilesInfo|
            lOutputFiles[iDeliverable.ID] = iFilesInfo
          end
          File.open(@OutputFileName, 'w') do |oFile|
            oFile.write(lOutputFiles.inspect)
          end
        end
      end

      private

      # List files for a given deliverable.
      #
      # Parameters:
      # * *iDeliverable* (_Deliverable_): Deliverable to fetch
      def listDeliverable(iDeliverable)
        lVODir = iDeliverable.VersionedObject.RealDir
        @LstSrcFiles.concat(Dir.glob("#{lVODir}/Source/**/*"))
        # Get all metadata.conf.rb from the VersionedObject to the root directory
        lCurrentDir = lVODir.clone
        while (true)
          lMetadataFileName = "#{lCurrentDir}/metadata.conf.rb"
          if (File.exists?(lMetadataFileName))
            @LstSrcFiles << lMetadataFileName
          end
          if (lCurrentDir == @Proxy.RootDir)
            break
          else
            lCurrentDir = File.dirname(lCurrentDir)
          end
        end
        # If this deliverable is not built using a fully automated process, we must also include the deliverable result files
        lProcessInfo, lProcessParameters = iDeliverable.getProcessInfo
        if ((lProcessInfo == nil) or
            (!lProcessInfo[:FullyAutomated]))
          # We also need the deliverable files
          if (File.exists?(iDeliverable.RealDir))
            @LstManualDeliverableFiles.concat(Dir.glob("#{iDeliverable.RealDir}/**/*"))
          else
            @LstManualMissingDeliverables << iDeliverable.ID
          end
        end
      end
      
    end
    
  end
  
end
