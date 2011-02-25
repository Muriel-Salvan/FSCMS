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
        @LstFiles = {}
        @Proxy.foreachDeliverable(@LstTargets) do |iDeliverable|
          @LstDeliverableFiles = []
          @Proxy.visitDeliverable(iDeliverable, true) do |iVisitedDeliverable|
            listDeliverable(iVisitedDeliverable)
          end
          @LstFiles[iDeliverable] = @LstDeliverableFiles.uniq.sort
        end
        # Display and store
        @LstFiles.each do |iDeliverable, iLstFiles|
          logMsg "===== Files needed for deliverable #{iDeliverable.ID}:\n  * #{iLstFiles.join("\n  * ")}\n\n"
        end
        if (@OutputFileName != nil)
          lOutputFiles = {}
          @LstFiles.each do |iDeliverable, iLstFiles|
            lOutputFiles[iDeliverable.ID] = iLstFiles
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
        @LstDeliverableFiles.concat(Dir.glob("#{lVODir}/Source/**/*"))
        # Get all metadata.conf.rb from the VersionedObject to the root directory
        lCurrentDir = lVODir.clone
        while (true)
          lMetadataFileName = "#{lCurrentDir}/metadata.conf.rb"
          if (File.exists?(lMetadataFileName))
            @LstDeliverableFiles << lMetadataFileName
          end
          if (lCurrentDir == @Proxy.RootDir)
            break
          else
            lCurrentDir = File.dirname(lCurrentDir)
          end
        end
      end
      
    end
    
  end
  
end
