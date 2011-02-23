#--
# Copyright (c) 2009-2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module FSCMS

  class Proxy

    # Constructor
    #
    # Parameters:
    # * *ioDB* (_Database_): The database of objects, versions, deliverables...
    def initialize(ioDB)
      @DB = ioDB
    end

    # Get the list of deliverables corresponding to a given target
    # Examples of targets:
    # * MusicTracks/RR126/0.1.20101102/WAV_192kHz_24bits: A given deliverable
    # * MusicTracks/RR126/Previews/30s/0.1.20101010/WAV_192kHz_24bits: A given deliverable with a hierarchical ID
    # * MusicTracks/RR126/0.1.20101102: All deliverables of a given object version
    # * MusicTracks/RR126: All deliverables of all versions of a given object
    # * MusicTracks: All music tracks, all versions, all deliverables
    #
    # Parameters:
    # * *iTarget* (_String_): The Target representation
    # Return:
    # * <em>list<DeliverableTarget></em>: The corresponding list of deliverable targets
    def getDeliverableTargets(iTarget)
      rDeliverables = []

      # Parse the target
      lTypeName = nil
      lLstID = []
      lVersionName = nil
      lDeliverableName = nil
      iTarget.split('/').each do |iTargetToken|
        if (lTypeName == nil)
          # The first token is the type name
          lTypeName = iTargetToken
        elsif (lVersionName == nil)
          lFirstChar = iTargetToken.getbyte(0)
          if ((lFirstChar >= 48) and
              (lFirstChar <= 57))
            # This token is the version
            lVersionName = iTargetToken
          else
            # This token completes the ID
            lLstID << iTargetToken
          end
        elsif (lDeliverableName == nil)
          # This token is forcefully the deliverable
          lDeliverableName = iTargetToken
        else
          raise RuntimeError.new("Invalid target (#{iTarget}): token #{iTargetToken} does not correspond to anything")
        end
      end

      # Get the corresponding objects
      if (lLstID.empty?)
        # All deliverables from all versioned objects from all objects from this type
        @DB.getObjects(lTypeName).each do |iID, iObject|
          iObject.getVersionedObjects.each do |iVersion, iVersionedObject|
            iVersionedObject.getDeliverables.each do |iDeliverableName, iDeliverable|
              rDeliverables << iDeliverable
            end
          end
        end
      elsif (lVersionName == nil)
        # All deliverables from all versioned objects from this object
        @DB.getVersionedObjects(lTypeName, lLstID).each do |iVersion, iVersionedObject|
          iVersionedObject.getDeliverables.each do |iDeliverableName, iDeliverable|
            rDeliverables << iDeliverable
          end
        end
      elsif (lDeliverableName == nil)
        # All deliverables from this versioned object
        @DB.getDeliverables(lTypeName, lLstID, lVersionName).each do |iDeliverableName, iDeliverable|
          rDeliverables << iDeliverable
        end
      else
        rDeliverables << @DB.getDeliverable(lTypeName, lLstID, lVersionName, lDeliverableName)
      end

      return rDeliverables
    end

    # Replace aliases in a string
    #
    # Parameters:
    # * *iStr* (_String_): The string containing aliases
    # * *iAliases* (<em>map<String,String></em>): The aliases definitions
    # Return:
    # * _String_: The string without aliases
    def replaceAliases(iStr, iAliases)
      rStr = iStr.clone

      lMatch = rStr.match(/^(.*)@\{([^\}]*)\}(.*)$/)
      while (lMatch != nil)
        lAliasName = lMatch[2]
        if (iAliases[lAliasName] == nil)
          raise RuntimeError.new("Unknown alias #{lAliasName} in string #{iStr}. Current aliases are: #{iAliases.inspect}.")
        else
          rStr = "#{lMatch[1]}#{iAliases[lAliasName]}#{lMatch[3]}"
        end
        lMatch = rStr.match(/^(.*)@\{([^\}]*)\}(.*)$/)
      end

      return rStr
    end

  end

end