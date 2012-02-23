#--
# Copyright (c) 2010 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module FSCMS

  class Proxy

    # The root directory
    #   String
    attr_reader :RootDir

    # Constructor
    #
    # Parameters::
    # * *ioDB* (_Database_): The database of objects, versions, deliverables...
    # * *iRootDir* (_String_): The root directory
    def initialize(ioDB, iRootDir)
      @RootDir = iRootDir
      @DB = ioDB
    end

    # Get the list of deliverables corresponding to a given target
    # Examples of targets:
    # * MusicTracks/RR126/0.1.20101102/WAV_192kHz_24bits: A given deliverable
    # * MusicTracks/RR126/Previews/30s/0.1.20101010/WAV_192kHz_24bits: A given deliverable with a hierarchical ID
    # * MusicTracks/RR126/0.1.20101102: All deliverables of a given object version
    # * MusicTracks/RR126: All deliverables of all versions of a given object, or sub-objects
    # * MusicTracks: All music tracks, all versions, all deliverables
    #
    # Parameters::
    # * *iTarget* (_String_): The Target representation
    # Return::
    # * <em>list<Deliverable></em>: The corresponding list of deliverable targets
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
        # All deliverables from all versioned objects from this object, or any part of it
        # Gather also the list of objects who begin with this object ID (ex.: TestID will return TestID/0.1 and also TestID/SubTestID/0.1)
        lObjects = []
        @DB.getObjects(lTypeName).each do |iID, iObjectInfo|
          if (iID[0..lLstID.size-1] == lLstID)
            lObjects << iObjectInfo
          end
        end
        if (lObjects.empty?)
          raise RuntimeError.new("No object could match ID #{lTypeName}/#{lLstID.join('/')}")
        else
          lObjects.each do |iObjectInfo|
            iObjectInfo.getVersionedObjects.each do |iVersion, iVersionedObject|
              iVersionedObject.getDeliverables.each do |iDeliverableName, iDeliverable|
                rDeliverables << iDeliverable
              end
            end
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

    # Replace aliases and parse for references in this deliverable's context.
    # Get the list of deliverables that are a dependency for this deliverable.
    #
    # Parameters::
    # * *ioDeliverable* (_Deliverable_): The deliverable for which we replace aliases
    # * *oDependencies* (<em>map<Deliverable,nil></em>): The list of dependencies to be completed
    def getDeliverableDependencies(ioDeliverable, oDependencies)
      # Look for references in cmd, dir and parameters of the process
      lProcessInfo, lProcessParams = ioDeliverable.getProcessInfo
      if (lProcessInfo != nil)
        lAliases = ioDeliverable.Context.Aliases.merge(params2aliases(lProcessParams))
        replaceAliases(lProcessInfo[:Dir], lAliases, oDependencies)
        replaceAliases(lProcessInfo[:Cmd], lAliases, oDependencies)
        lProcessParams.each do |iParam, iValue|
          replaceAliases(iValue, lAliases, oDependencies)
        end
      end
    end

    # Get the aliases hash map from process parameters
    #
    # Parameters::
    # * *iProcessParams* (<em>map<Symbol,String></em>): The process parameters
    # Return::
    # * <em>map<String,String></em>: The corresponding aliases
    def params2aliases(iProcessParams)
      rAliases = {}

      iProcessParams.each do |iSymKey, iValue|
        rAliases[iSymKey.to_s] = iValue
      end

      return rAliases
    end

    # Replace aliases in a string
    #
    # Parameters::
    # * *iStr* (_String_): The string containing aliases
    # * *iAliases* (<em>map<String,String></em>): The aliases definitions
    # * *oDependencies* (<em>map<Deliverable,nil></em>): The dependencies to be completed. If this is not nil, the properties in Ref aliases will be simply deleted from the string, as this should be used to know dependencies, and dependencies can't have properties set if they are not built yet. [optional = nil]
    # Return::
    # * _String_: The string without aliases
    def replaceAliases(iStr, iAliases, oDependencies = nil)
      rStr = iStr.clone

      lMatch = rStr.match(/^(.*)@\{([^\}]*)\}(.*)$/)
      while (lMatch != nil)
        lAliasName = lMatch[2]
        if (lAliasName[0..3] == 'Ref[')
          # We have a reference to another deliverable
          lTargetTokens = lAliasName[4..-2].split('/')
          # Check if there is a property reference at the end
          lTargetMatch = lTargetTokens[-1].match(/^(.*)\.([^\.]*)$/)
          if (lTargetMatch == nil)
            # No property reference
            lDeps = getDeliverableTargets(lTargetTokens.join('/'))
            if (lDeps.size == 1)
              rStr = "#{lMatch[1]}#{lDeps[0].RealDir}#{lMatch[3]}"
              if (oDependencies != nil)
                oDependencies[lDeps[0]] = nil
              end
            else
              raise RuntimeError.new("Reference #{lAliasName} resolves to #{lDeps.size} deliverables.")
            end
          else
            # There is a property reference
            lDeps = getDeliverableTargets((lTargetTokens[0..-2] + [ lTargetMatch[1] ]).join('/'))
            if (lDeps.size == 1)
              if (oDependencies == nil)
                # Read properties from this deliverable result
                lProperties = nil
                File.open("#{lDeps[0].RealDir}/metadata.conf.rb", 'r') do |iFile|
                  lProperties = eval(iFile.read)
                end
                lPropertyValue = lProperties[lTargetMatch[2].to_sym]
                if (lPropertyValue == nil)
                  raise RuntimeError.new("No property named #{lTargetMatch[2]} could be found in deliverable #{lDeps[0].ID}. Unable to resolve #{lAliasName}.")
                else
                  rStr = "#{lMatch[1]}#{replaceAliases(lPropertyValue, lDeps[0].Context.Aliases)}#{lMatch[3]}"
                end
              else
                # Just remove this reference from the string
                rStr = "#{lMatch[1]}#{lMatch[3]}"
                oDependencies[lDeps[0]] = nil
              end
            else
              raise RuntimeError.new("Reference #{lAliasName} resolves to #{lDeps.size} deliverables.")
            end
          end
        elsif (iAliases[lAliasName] == nil)
          raise RuntimeError.new("Unknown alias #{lAliasName} in string #{iStr}. Current aliases are: #{iAliases.inspect}.")
        else
          rStr = "#{lMatch[1]}#{iAliases[lAliasName]}#{lMatch[3]}"
        end
        lMatch = rStr.match(/^(.*)@\{([^\}]*)\}(.*)$/)
      end

      return rStr
    end

    # Visit a list of deliverables based on a list of targets.
    #
    # Parameters::
    # * *iLstTargets* (<em>list<String></em>): The list of targets to consider
    # * *CodeBlock*: The code called for each deliverable found
    #   * Parameters::
    #     * *iDeliverable* (_Deliverable_): The deliverable
    def foreachDeliverable(iLstTargets)
      # Compute the list of deliverables
      # list<Deliverable>
      lLstDeliverables = []
      iLstTargets.each do |iTarget|
        # Get the corresponding deliverables
        lLstDeliverables += getDeliverableTargets(iTarget)
      end
      lLstDeliverables.uniq.each do |iDeliverable|
        yield(iDeliverable)
      end
    end

    # Visit a deliverable eventually with its dependencies
    #
    # Parameters::
    # * *iDeliverable* (_Deliverable_): Deliverable to visit
    # * *iIncludeDependencies* (_Boolean_): Do we visit dependencies also ?
    # * *CodeBlock*: The code called for each deliverable found
    #   * Parameters::
    #     * *iDeliverable* (_Deliverable_): The deliverable
    def visitDeliverable(iDeliverable, iIncludeDependencies)
      if (iIncludeDependencies)
        lDependencies = {}
        getDeliverableDependencies(iDeliverable, lDependencies)
        lDependencies.each do |iDepDeliverable, iNil|
          log_info "Found dependency #{iDepDeliverable.ID}"
          visitDeliverable(iDepDeliverable, iIncludeDependencies) do |iDependencyDeliverable|
            yield(iDependencyDeliverable)
          end
        end
      end
      yield(iDeliverable)
    end

  end

end