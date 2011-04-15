#--
# Copyright (c) 2010 - 2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
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
          # The list of work files of any needed deliverable
          # list< String>
          @LstWorkFiles = []
          # The list of temp files
          # list< String >
          @LstTempFiles = []
          # The list of deliverable files created from an automatic process
          # list< String >
          @LstAutoDeliverableFiles = []
          # The list of deliverables that are needed as automatic processes, but are not built now
          # list< String >
          @LstAutoMissingDeliverables = []
          @Proxy.visitDeliverable(iDeliverable, true) do |iVisitedDeliverable|
            listDeliverable(iVisitedDeliverable)
          end
          lLstFiles[iDeliverable.ID] = {
            :Sources => @LstSrcFiles.uniq.sort,
            :ManualDeliverables => @LstManualDeliverableFiles.uniq.sort,
            :ManualMissingDeliverables => @LstManualMissingDeliverables.uniq.sort,
            :Work => @LstWorkFiles.uniq.sort,
            :Temp => @LstTempFiles.uniq.sort,
            :AutoDeliverables => @LstAutoDeliverableFiles.uniq.sort,
            :AutoMissingDeliverables => @LstAutoMissingDeliverables.uniq.sort
          }
        end
        # Display and store
        lLstFiles.each do |iDeliverableID, iFilesInfo|
          logMsg "== Deliverable #{iDeliverableID}
=== Critical source files:
  * #{iFilesInfo[:Sources].join("\n  * ")}
=== Manual deliverable files:
  * #{iFilesInfo[:ManualDeliverables].join("\n  * ")}
=== Manual deliverables missing files now:
  * #{iFilesInfo[:ManualMissingDeliverables].join("\n  * ")}
=== Work files:
  * #{iFilesInfo[:Work].join("\n  * ")}
=== Temporary files:
  * #{iFilesInfo[:Temp].join("\n  * ")}
=== Automatic deliverable files:
  * #{iFilesInfo[:AutoDeliverables].join("\n  * ")}
=== Automatic deliverables missing files now:
  * #{iFilesInfo[:AutoMissingDeliverables].join("\n  * ")}

"
        end
        if (@OutputFileName != nil)
          File.open(@OutputFileName, 'w') do |oFile|
            oFile.write(lLstFiles.inspect)
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
        else
          # We get the automatic files too
          if (File.exists?(iDeliverable.RealDir))
            @LstAutoDeliverableFiles.concat(Dir.glob("#{iDeliverable.RealDir}/**/*"))
          else
            @LstAutoMissingDeliverables << iDeliverable.ID
          end
        end
        # Get the Work files
        if (File.exists?("#{lVODir}/Work"))
          @LstWorkFiles.concat(Dir.glob("#{lVODir}/Work/**/*"))
        end
        # Get the Temporary files
        if (File.exists?("#{lVODir}/Temp/#{iDeliverable.ID.split('/')[-1]}"))
          @LstTempFiles.concat(Dir.glob("#{lVODir}/Temp/#{iDeliverable.ID.split('/')[-1]}/**/*"))
        end
      end
      
    end
    
  end
  
end
