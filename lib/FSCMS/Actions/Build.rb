#--
# Copyright (c) 2009-2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

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

        # Initialize properties that will be set by the options parser
        rOptions.on( '--target <TargetName>', String,
          '<TargetName>: Name of target to build (ex.: TrackMusics/RR126/0.1.20101102/WAV_192kHz_24bits)',
          'Set a Target to build (can be specified several times).') do |iArg|
          @LstTargets << iArg
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
          lLstDeliverables << @Proxy.getDeliverableTargets(iTarget)
        end
        
        lLstDeliverables.each do |i|
          p i.RealDir
        end
      end
      
    end
    
  end
  
end
