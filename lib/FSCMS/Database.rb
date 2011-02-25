#--
# Copyright (c) 2009-2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module FSCMS

  class Database

    # The database object storing a context.
    # A context is made of aliases, references, properties that are gathered through metadata configuration files.
    # A context automatically includes information from its parent contexts.
    class Context

      # The list of aliases
      #   map< String, String >
      attr_accessor :Aliases

      # The list of processes
      #   map< Symbol, Object >
      attr_accessor :Processes

      # The other properties of this context
      #   map< Symbol, Object >
      attr_accessor :Properties

      # Constructor
      def initialize
        @Aliases = {}
        @Processes = {}
        @Properties = {}
      end

      # Merge with a context from a directory
      #
      # Parameters:
      # * *iDirName* (_String_): Directory to merge context with
      def mergeWithDirContext(iDirName)
        lContextFileName = "#{iDirName}/metadata.conf.rb"
        if (File.exists?(lContextFileName))
          File.open(lContextFileName, 'r') do |iFile|
            mergeWithHashContext(eval(iFile.read))
          end
        end
      end

      # Merge with a context
      #
      # Parameters:
      # * *iContext* (_Context_): The context to merge with
      def mergeWithContext(iContext)
        @Processes.merge!(iContext.Processes)
        @Aliases.merge!(iContext.Aliases)
        @Properties.merge!(iContext.Properties)
      end

      # Merge with a hashed context
      #
      # Parameters:
      # * *iContext* (<em>map<Symbol,Object></em>): The context to merge with
      def mergeWithHashContext(iContext)
        iContext.each do |iKey, iValue|
          case iKey
          when :Processes
            # Define new processes
            @Processes.merge!(iValue)
          when :Aliases
            # Define new aliases
            @Aliases.merge!(iValue)
          else
            @Properties[iKey] = iValue
          end
        end
      end

      # Clone this Context
      #
      # Return:
      # * _Context_: New context, cloned
      def clone
        rContext = Context.new

        rContext.mergeWithContext(self)

        return rContext
      end

    end
    
    # The database object storing info about a Type
    class Type
      
      # The associated context
      #   Context
      attr_accessor :Context
      
      # The map of objects
      #   map< list< String >, ObjectInfo >
      attr_accessor :Objects

      # The ID
      #   String
      attr_reader :ID
      
      # Constructor
      #
      # Parameters:
      # * *iRealDir* (_String_): The directory containing this type
      # * *iContext* (_Context_): The parent context
      # * *iID* (_String_): The ID
      def initialize(iRealDir, iContext, iID)
        @RealDir, @ID = iRealDir, iID
        @Context = Context.new
        @Objects = nil
        # Read its context
        @Context.mergeWithContext(iContext)
        @Context.mergeWithDirContext(@RealDir)
      end

      # Get objects
      #
      # Return:
      # * <em>map<list<String>,ObjectInfo></em>: Get the list of objects
      def getObjects
        readObjects

        return @Objects
      end

      private

      # Read objects
      def readObjects
        if (@Objects == nil)
          @Objects = {}
          parseIDDirs(@RealDir, @Context).each do |iID, iIDInfo|
            iRealDir, iContext = iIDInfo
            @Objects[iID] = ObjectInfo.new(self, "#{@RealDir}/#{iRealDir}", iContext, "#{@ID}/#{iID.join('/')}")
            logDebug "Found object #{@RealDir}/#{iRealDir}"
          end
        end
      end

      # Get the list of ID directories with their corresponding real directories under a given root directory
      #
      # Parameters:
      # * *iRootDir* (_String_): The directory
      # * *iRootContext* (_Context_): The context of this root directory
      # Return:
      # * <em>map<list<String>,[String,Context]></em>: The list of IDs, and corresponding real directories and context
      def parseIDDirs(iRootDir, iRootContext)
        rIDs = {}

        Dir.glob("#{iRootDir}/*").each do |iDirName|
          lDirToken = File.basename(iDirName)
          lFirstChar = lDirToken.getbyte(0)
          if ((lFirstChar >= 48) and
              (lFirstChar <= 57))
            # We have the version directory
            rIDs[[]] = [ '', iRootContext ]
          else
            # A sub-directory
            lIDToken = lDirToken.split(' ')[0]
            lContext = Context.new
            lContext.mergeWithContext(iRootContext)
            lContext.mergeWithDirContext("#{iRootDir}/#{lDirToken}")
            parseIDDirs("#{iRootDir}/#{lDirToken}", lContext).each do |iSubID, iSubInfo|
              iSubRealDir, iSubContext = iSubInfo
              if (iSubRealDir.empty?)
                rIDs[[lIDToken] + iSubID] = [ lDirToken, iSubContext ]
              else
                rIDs[[lIDToken] + iSubID] = [ "#{lDirToken}/#{iSubRealDir}", iSubContext ]
              end
            end
          end
        end

        return rIDs
      end

    end
    
    # The database object storing info about an object
    class ObjectInfo
      
      # The associated context
      #   Context
      attr_accessor :Context
      
      # The real directory
      #   String
      attr_accessor :RealDir
      
      # The list of objects
      #   map< String, VersionedObject >
      attr_accessor :VersionedObjects

      # The ID
      #   String
      attr_reader :ID
      
      # Constructor
      #
      # Parameters:
      # * *iType* (_Type_): The parent type
      # * *iRealDir* (_String_): The real directory
      # * *iContext* (_Context_): The context of this object
      # * *iID* (_String_): The ID
      def initialize(iType, iRealDir, iContext, iID)
        @Type, @RealDir, @Context, @ID = iType, iRealDir, iContext.clone, iID
        @VersionedObjects = nil
      end

      # Get the list of versioned objects
      #
      # Return:
      # * <em>map<String,VersionedObject></em>: The list of versioned objects, per version
      def getVersionedObjects
        readVersionedObjects

        return @VersionedObjects
      end

      private

      # Read versioned objects
      def readVersionedObjects
        if (@VersionedObjects == nil)
          @VersionedObjects = {}
          Dir.glob("#{@RealDir}/*").each do |iDirName|
            lDirToken = File.basename(iDirName)
            lFirstChar = lDirToken.getbyte(0)
            if ((lFirstChar >= 48) and
                (lFirstChar <= 57))
              # We have a version directory
              lVersion = lDirToken.split(' ')[0]
              @VersionedObjects[lVersion] = VersionedObject.new(self, "#{@RealDir}/#{lDirToken}", "#{@ID}/#{lVersion}")
              logDebug "Found versioned object #{@RealDir}/#{lDirToken}"
            end
          end
        end
      end
      
    end
    
    # The database object storing info about a versioned object
    class VersionedObject
      
      # The associated context
      #   Context
      attr_accessor :Context
      
      # The real directory
      #   String
      attr_accessor :RealDir
      
      # The list of deliverables
      #   map< String, Deliverable >
      attr_accessor :Deliverables

      # The ID
      #   String
      attr_reader :ID
      
      # Constructor
      #
      # Parameters:
      # * *iObject* (_ObjectInfo_): The parent object
      # * *iRealDir* (_String_): The directory containing this versioned object
      # * *iID* (_String_): The ID
      def initialize(iObject, iRealDir, iID)
        @Object, @RealDir, @ID = iObject, iRealDir, iID
        @Deliverables = nil
        @Context = iObject.Context.clone
        @Context.mergeWithDirContext(@RealDir)
        # Set forced aliases
        @Context.mergeWithHashContext( {
          :Aliases => {
            'SourceDir' => "#{iRealDir}/Source"
          }
        } )
      end

      # Get deliverables
      #
      # Return:
      # * <em>map<String,Deliverable></em>: The list of deliverables, per deliverable name
      def getDeliverables
        readDeliverables

        return @Deliverables
      end

      private

      # Read deliverables
      def readDeliverables
        if (@Deliverables == nil)
          @Deliverables = {}
          # First, check deliverables from disk
          if (File.exists?("#{@RealDir}/Deliverables"))
            Dir.glob("#{@RealDir}/Deliverables/*").each do |iDirName|
              lDirToken = File.basename(iDirName)
              lDeliverableName = lDirToken.split(' ')[0]
              # Find its context
              lContext = @Context.clone
              if ((@Context.Properties[:Deliverables] != nil) and
                  (@Context.Properties[:Deliverables][lDeliverableName] != nil))
                lContext.mergeWithHashContext(@Context.Properties[:Deliverables][lDeliverableName])
              end
              @Deliverables[lDeliverableName] = Deliverable.new(self, "#{@RealDir}/Deliverables/#{lDirToken}", lContext, "#{@ID}/#{lDeliverableName}")
              logDebug "Found deliverable from file system #{@RealDir}/Deliverables/#{lDirToken}"
            end
          end
          # Then from the config file
          if (@Context.Properties[:Deliverables] != nil)
            @Context.Properties[:Deliverables].each do |iDeliverableName, iDeliverableContext|
              if (@Deliverables[iDeliverableName] == nil)
                lContext = @Context.clone
                lContext.mergeWithHashContext(iDeliverableContext)
                @Deliverables[iDeliverableName] = Deliverable.new(self, "#{@RealDir}/Deliverables/#{iDeliverableName}", lContext, "#{@ID}/#{iDeliverableName}")
                logDebug "Found deliverable from metadata #{@RealDir}/Deliverables/#{iDeliverableName}"
              end
            end
          end
        end
      end
      
    end
    
    # The database object storing info about a deliverable
    class Deliverable
      
      # The associated context
      #   Context
      attr_accessor :Context
      
      # The real directory
      #   String
      attr_accessor :RealDir

      # The corresponding versioned object
      #   VersionedObject
      attr_reader :VersionedObject

      # The ID of this deliverable
      #   String
      attr_reader :ID
      
      # Constructor
      #
      # Parameters:
      # * *iVersionedObject* (_VersionedObject_): The parent versioned object
      # * *iRealDir* (_String_): The real directory containing this deliverable
      # * *iContext* (_Context_): The deliverable context
      # * *iID* (_String_): The ID
      def initialize(iVersionedObject, iRealDir, iContext, iID)
        @VersionedObject, @RealDir, @Context, @ID = iVersionedObject, iRealDir, iContext.clone, iID
        # Set forced aliases
        @Context.mergeWithHashContext( {
          :Aliases => {
            'DeliverableDir' => @RealDir,
            'TempDir' => "#{@VersionedObject.RealDir}/Temp/#{File.basename(@RealDir).split(' ')[0]}"
          }
        } )
      end

      # Get the process info associated to this deliverable
      #
      # Return:
      # * <em>map<Symbol,Object></em>: The process info, or nil if none
      # * <em>map<Symbol,Object></em>: The process parameters
      def getProcessInfo
        rProcessInfo = nil
        rProcessParams = nil

        if (@Context.Properties[:Execute] != nil)
          lSymProcess = @Context.Properties[:Execute][:Process]
          rProcessInfo = @Context.Processes[lSymProcess]
          if (rProcessInfo == nil)
            raise RuntimeError.new("No process info associated to #{lSymProcess.to_s}")
          end
          rProcessParams = @Context.Properties[:Execute][:Parameters] || {}
        end

        return rProcessInfo, rProcessParams
      end

    end

    # The root context
    #   Context
    attr_reader :Context

    # Constructor
    #
    # Parameters:
    # * *iRootDir* (_String_): The root directory containing the files
    def initialize(iRootDir)
      @RootDir = iRootDir
      @Context = Context.new
      # The internal database
      # map< String, Type >
      @DB = nil
      @Context.mergeWithDirContext(iRootDir)
    end

    # Get the list of objects for a given type name
    #
    # Parameters:
    # * *iTypeName* (_String_): The type
    # Return:
    # * <em>map<list<String>,ObjectInfo></em>: The list of objects, per ID
    def getObjects(iTypeName)
      return getType(iTypeName).getObjects
    end

    # Get the list of versioned objects for a given type name and object ID
    #
    # Parameters:
    # * *iTypeName* (_String_): The type
    # * *iObjectID* (_String_): The object ID
    # Return:
    # * <em>map<String,VersionedObject></em>: The list of versioned objects, per version
    def getVersionedObjects(iTypeName, iObjectID)
      lObjects = getObjects(iTypeName)
      if (lObjects[iObjectID] == nil)
        raise RuntimeError.new("Unable to get object #{iTypeName}/#{iObjectID.join('/')}")
      end

      return lObjects[iObjectID].getVersionedObjects
    end

    # Get the list of deliverables for a given type name, object ID, version
    #
    # Parameters:
    # * *iTypeName* (_String_): The type
    # * *iObjectID* (_String_): The object ID
    # * *iVersion* (_String_): The version
    # Return:
    # * <em>map<String,Deliverable></em>: The list of deliverables, per name
    def getDeliverables(iTypeName, iObjectID, iVersion)
      lVersionedObjects = getVersionedObjects(iTypeName, iObjectID)
      if (lVersionedObjects[iVersion] == nil)
        raise RuntimeError.new("Unable to get versioned object #{iTypeName}/#{iObjectID.join('/')}/#{iVersion}")
      end

      return lVersionedObjects[iVersion].getDeliverables
    end

    # Get the specified deliverable
    #
    # Parameters:
    # * *iTypeName* (_String_): The type
    # * *iObjectID* (_String_): The object ID
    # * *iVersion* (_String_): The version
    # * *iDeliverableName* (_String_): The deliverable name
    # Return:
    # * _Deliverable_: The deliverable
    def getDeliverable(iTypeName, iObjectID, iVersion, iDeliverableName)
      lDeliverables = getDeliverables(iTypeName, iObjectID, iVersion)
      if (lDeliverables[iDeliverableName] == nil)
        raise RuntimeError.new("Unable to get deliverable #{iTypeName}/#{iObjectID.join('/')}/#{iVersion}/#{iDeliverableName}")
      end

      return lDeliverables[iDeliverableName]
    end

    private

    # Get a given type
    # Raises an exception if the type does not exist
    #
    # Parameters:
    # * *iTypeName* (_String_): The type name to get
    # Return:
    # * _Type_: The corresponding type
    def getType(iTypeName)
      readTypes
      if (@DB.has_key?(iTypeName))
        if (@DB[iTypeName] == nil)
          # Create it
          lType = Type.new("#{@RootDir}/#{iTypeName}", @Context, iTypeName)
          @DB[iTypeName] = lType
        end
      else
        raise RuntimeError.new("Unknown type #{iTypeName} from database.")
      end

      return @DB[iTypeName]
    end

    # Read types
    def readTypes
      if (@DB == nil)
        @DB = {}
        Dir.glob("#{@RootDir}/*").each do |iDirName|
          @DB[File.basename(iDirName)] = nil
        end
      end
    end

  end

end