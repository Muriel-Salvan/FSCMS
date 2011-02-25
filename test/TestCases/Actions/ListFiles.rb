#--
# Copyright (c) 2009-2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module FSCMSTest

  module Actions

    class ListFiles < ::Test::Unit::TestCase

      include FSCMSTest::Common

      # Test that a single deliverable lists files correctly
      def testListSingleDeliverable
        setRepository('UniqueDeliverable') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID/0.1/TestDeliverable' => {
                  :Sources => [
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile1",
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile2",
                    "#{iRepoDir}/TestType/TestID/0.1/metadata.conf.rb"
                  ],
                  :ManualDeliverables => [],
                  :ManualMissingDeliverables => [],
                  :Work => [],
                  :Temp => [],
                  :AutoDeliverables => [],
                  :AutoMissingDeliverables => [ 'TestType/TestID/0.1/TestDeliverable' ]
                }
              }, eval(iFile.read))
          end
        end
      end

      # Test that a single deliverable lists files correctly even if it is already built
      def testListSingleExistingDeliverable
        setRepository('UniqueExistingDeliverable') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID/0.1/TestDeliverable' => {
                  :Sources => [
                    "#{iRepoDir}/TestType/TestID/0.1/metadata.conf.rb"
                  ],
                  :ManualDeliverables => [],
                  :ManualMissingDeliverables => [],
                  :Work => [],
                  :Temp => [],
                  :AutoDeliverables => [ "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/DeliverableFile" ],
                  :AutoMissingDeliverables => []
                }
              }, eval(iFile.read))
          end
        end
      end

      # Test that a single deliverable lists files correctly, with Work, Temp
      def testListSingleDeliverableWorkTemp
        setRepository('DependencyWithWorkTemp') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID1/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID1/0.1/TestDeliverable' => {
                  :Sources => [ "#{iRepoDir}/TestType/TestID1/0.1/metadata.conf.rb" ],
                  :ManualDeliverables => [],
                  :ManualMissingDeliverables => [],
                  :Work => [
                    "#{iRepoDir}/TestType/TestID1/0.1/Work/SubDir1",
                    "#{iRepoDir}/TestType/TestID1/0.1/Work/SubDir1/SubSubDir",
                    "#{iRepoDir}/TestType/TestID1/0.1/Work/SubDir1/SubSubDir/WorkFile4",
                    "#{iRepoDir}/TestType/TestID1/0.1/Work/SubDir1/WorkFile2",
                    "#{iRepoDir}/TestType/TestID1/0.1/Work/SubDir2",
                    "#{iRepoDir}/TestType/TestID1/0.1/Work/SubDir2/WorkFile3",
                    "#{iRepoDir}/TestType/TestID1/0.1/Work/WorkFile1"
                  ],
                  :Temp => [
                    "#{iRepoDir}/TestType/TestID1/0.1/Temp/TestDeliverable/SubDir1",
                    "#{iRepoDir}/TestType/TestID1/0.1/Temp/TestDeliverable/SubDir1/SubSubDir",
                    "#{iRepoDir}/TestType/TestID1/0.1/Temp/TestDeliverable/SubDir1/SubSubDir/TempFile4",
                    "#{iRepoDir}/TestType/TestID1/0.1/Temp/TestDeliverable/SubDir1/TempFile2",
                    "#{iRepoDir}/TestType/TestID1/0.1/Temp/TestDeliverable/SubDir2",
                    "#{iRepoDir}/TestType/TestID1/0.1/Temp/TestDeliverable/SubDir2/TempFile3",
                    "#{iRepoDir}/TestType/TestID1/0.1/Temp/TestDeliverable/TempFile1"
                  ],
                  :AutoDeliverables => [],
                  :AutoMissingDeliverables => [ 'TestType/TestID1/0.1/TestDeliverable' ]
                }
              }, eval(iFile.read))
          end
        end
      end

      # Test that a single deliverable lists files correctly, with Work, Temp in dependencies
      def testListSingleDeliverableWorkTempInDependency
        setRepository('DependencyWithWorkTemp') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID2/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID2/0.1/TestDeliverable' => {
                  :Sources => [
                    "#{iRepoDir}/TestType/TestID1/0.1/metadata.conf.rb",
                    "#{iRepoDir}/TestType/TestID2/0.1/metadata.conf.rb"
                  ],
                  :ManualDeliverables => [],
                  :ManualMissingDeliverables => [],
                  :Work => [
                    "#{iRepoDir}/TestType/TestID1/0.1/Work/SubDir1",
                    "#{iRepoDir}/TestType/TestID1/0.1/Work/SubDir1/SubSubDir",
                    "#{iRepoDir}/TestType/TestID1/0.1/Work/SubDir1/SubSubDir/WorkFile4",
                    "#{iRepoDir}/TestType/TestID1/0.1/Work/SubDir1/WorkFile2",
                    "#{iRepoDir}/TestType/TestID1/0.1/Work/SubDir2",
                    "#{iRepoDir}/TestType/TestID1/0.1/Work/SubDir2/WorkFile3",
                    "#{iRepoDir}/TestType/TestID1/0.1/Work/WorkFile1"
                  ],
                  :Temp => [
                    "#{iRepoDir}/TestType/TestID1/0.1/Temp/TestDeliverable/SubDir1",
                    "#{iRepoDir}/TestType/TestID1/0.1/Temp/TestDeliverable/SubDir1/SubSubDir",
                    "#{iRepoDir}/TestType/TestID1/0.1/Temp/TestDeliverable/SubDir1/SubSubDir/TempFile4",
                    "#{iRepoDir}/TestType/TestID1/0.1/Temp/TestDeliverable/SubDir1/TempFile2",
                    "#{iRepoDir}/TestType/TestID1/0.1/Temp/TestDeliverable/SubDir2",
                    "#{iRepoDir}/TestType/TestID1/0.1/Temp/TestDeliverable/SubDir2/TempFile3",
                    "#{iRepoDir}/TestType/TestID1/0.1/Temp/TestDeliverable/TempFile1"
                  ],
                  :AutoDeliverables => [],
                  :AutoMissingDeliverables => [
                    'TestType/TestID1/0.1/TestDeliverable',
                    'TestType/TestID2/0.1/TestDeliverable'
                  ]
                }
              }, eval(iFile.read))
          end
        end
      end

      # Test that a single deliverable lists files correctly even in sub-directories
      def testListSingleDeliverableSubDir
        setRepository('UniqueDeliverableSourceSubDir') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID/0.1/TestDeliverable' => {
                  :Sources => [
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile1",
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile2",
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SubDir1",
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SubDir1/SourceFile3",
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SubDir1/SubSubDir",
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SubDir1/SubSubDir/SourceFile5",
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SubDir2",
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SubDir2/SourceFile4",
                    "#{iRepoDir}/TestType/TestID/0.1/metadata.conf.rb"
                  ],
                  :ManualDeliverables => [],
                  :ManualMissingDeliverables => [],
                  :Work => [],
                  :Temp => [],
                  :AutoDeliverables => [],
                  :AutoMissingDeliverables => [ 'TestType/TestID/0.1/TestDeliverable' ]
                }
              }, eval(iFile.read))
          end
        end
      end

      # Test that a single deliverable lists files correctly even without sources
      def testListSingleDeliverableWithoutSource
        setRepository('UniqueDeliverableNoSource') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID/0.1/TestDeliverable' => {
                  :Sources => [ "#{iRepoDir}/TestType/TestID/0.1/metadata.conf.rb" ],
                  :ManualDeliverables => [],
                  :ManualMissingDeliverables => [],
                  :Work => [],
                  :Temp => [],
                  :AutoDeliverables => [],
                  :AutoMissingDeliverables => [ 'TestType/TestID/0.1/TestDeliverable' ]
                }
              }, eval(iFile.read))
          end
        end
      end

      # Test that a single deliverable lists files correctly even without sources and metadata
      def testListSingleDeliverableWithoutConf
        setRepository('UniqueExistingDeliverableNoConf') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID/0.1/TestDeliverable' => {
                  :Sources => [],
                  :ManualDeliverables => [ "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable/DeliverableFile" ],
                  :ManualMissingDeliverables => [],
                  :Work => [],
                  :Temp => [],
                  :AutoDeliverables => [],
                  :AutoMissingDeliverables => []
                }
              }, eval(iFile.read))
          end
        end
      end

      # Test that a single deliverable lists files correctly including metadata from parent directories
      def testListSingleDeliverableWithParents
        setRepository('UniqueDeliverableUserAliases') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID/0.1/TestDeliverable' => {
                  :Sources => [
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile1",
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile2",
                    "#{iRepoDir}/TestType/TestID/0.1/metadata.conf.rb",
                    "#{iRepoDir}/TestType/TestID/metadata.conf.rb",
                    "#{iRepoDir}/TestType/metadata.conf.rb",
                    "#{iRepoDir}/metadata.conf.rb"
                  ],
                  :ManualDeliverables => [],
                  :ManualMissingDeliverables => [],
                  :Work => [],
                  :Temp => [],
                  :AutoDeliverables => [],
                  :AutoMissingDeliverables => [ 'TestType/TestID/0.1/TestDeliverable' ]
                }
              }, eval(iFile.read))
          end
        end
      end

      # Test that 2 deliverables from the same object list files correctly
      def testList2DeliverablesSameVersionedObject
        setRepository('2Deliverables') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID/0.1/TestDeliverable1', '--target', 'TestType/TestID/0.1/TestDeliverable2', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID/0.1/TestDeliverable1' => {
                  :Sources => [
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile1",
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile2",
                    "#{iRepoDir}/TestType/TestID/0.1/metadata.conf.rb"
                  ],
                  :ManualDeliverables => [],
                  :ManualMissingDeliverables => [],
                  :Work => [],
                  :Temp => [],
                  :AutoDeliverables => [],
                  :AutoMissingDeliverables => [ 'TestType/TestID/0.1/TestDeliverable1' ]
                },
                'TestType/TestID/0.1/TestDeliverable2' => {
                  :Sources => [
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile1",
                    "#{iRepoDir}/TestType/TestID/0.1/Source/SourceFile2",
                    "#{iRepoDir}/TestType/TestID/0.1/metadata.conf.rb"
                  ],
                  :ManualDeliverables => [],
                  :ManualMissingDeliverables => [],
                  :Work => [],
                  :Temp => [],
                  :AutoDeliverables => [],
                  :AutoMissingDeliverables => [ 'TestType/TestID/0.1/TestDeliverable2' ]
                }
              }, eval(iFile.read))
          end
        end
      end

      # Test list an automated dependency
      def testListDependencyAuto
        setRepository('DeliverablesProcessDependency') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID2/0.1/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID2/0.1/TestDeliverable' => {
                  :Sources => [
                    "#{iRepoDir}/TestType/TestID1/0.1/Source/SourceFile1",
                    "#{iRepoDir}/TestType/TestID1/0.1/Source/SourceFile2",
                    "#{iRepoDir}/TestType/TestID1/0.1/metadata.conf.rb",
                    "#{iRepoDir}/TestType/TestID2/0.1/Source/SourceFile1",
                    "#{iRepoDir}/TestType/TestID2/0.1/Source/SourceFile2",
                    "#{iRepoDir}/TestType/TestID2/0.1/metadata.conf.rb"
                  ],
                  :ManualDeliverables => [],
                  :ManualMissingDeliverables => [],
                  :Work => [],
                  :Temp => [],
                  :AutoDeliverables => [],
                  :AutoMissingDeliverables => [
                    'TestType/TestID1/0.1/TestDeliverable',
                    'TestType/TestID2/0.1/TestDeliverable',
                  ]
                }
              }, eval(iFile.read))
          end
        end
      end

      # Test list a manual dependency not built yet
      def testListDependencyManualNotBuilt
        setRepository('DeliverablesProcessDependency') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID2/0.4/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID2/0.4/TestDeliverable' => {
                  :Sources => [
                    "#{iRepoDir}/TestType/TestID1/0.2/metadata.conf.rb",
                    "#{iRepoDir}/TestType/TestID2/0.4/metadata.conf.rb"
                  ],
                  :ManualDeliverables => [],
                  :ManualMissingDeliverables => [ 'TestType/TestID1/0.2/TestDeliverable' ],
                  :Work => [],
                  :Temp => [],
                  :AutoDeliverables => [],
                  :AutoMissingDeliverables => [ 'TestType/TestID2/0.4/TestDeliverable' ]
                }
              }, eval(iFile.read))
          end
        end
      end

      # Test list a manual dependency already built
      def testListDependencyManualAlreadyBuilt
        setRepository('DeliverablesProcessDependency') do |iRepoDir|
          lOutputFileName = "#{iRepoDir}/OutputList.conf.rb"
          runFSCMS(['ListFiles', '--', '--target', 'TestType/TestID2/0.5/TestDeliverable', '--output', lOutputFileName])
          assert(File.exists?(lOutputFileName))
          File.open(lOutputFileName, 'r') do |iFile|
            assert_equal( {
                'TestType/TestID2/0.5/TestDeliverable' => {
                  :Sources => [
                    "#{iRepoDir}/TestType/TestID1/0.3/metadata.conf.rb",
                    "#{iRepoDir}/TestType/TestID2/0.5/metadata.conf.rb"
                  ],
                  :ManualDeliverables => [
                    "#{iRepoDir}/TestType/TestID1/0.3/Deliverables/TestDeliverable/DeliverableFile1",
                    "#{iRepoDir}/TestType/TestID1/0.3/Deliverables/TestDeliverable/SubDir1",
                    "#{iRepoDir}/TestType/TestID1/0.3/Deliverables/TestDeliverable/SubDir1/DeliverableFile2",
                    "#{iRepoDir}/TestType/TestID1/0.3/Deliverables/TestDeliverable/SubDir1/SubSubDir",
                    "#{iRepoDir}/TestType/TestID1/0.3/Deliverables/TestDeliverable/SubDir1/SubSubDir/DeliverableFile4",
                    "#{iRepoDir}/TestType/TestID1/0.3/Deliverables/TestDeliverable/SubDir2",
                    "#{iRepoDir}/TestType/TestID1/0.3/Deliverables/TestDeliverable/SubDir2/DeliverableFile3"
                  ],
                  :ManualMissingDeliverables => [],
                  :Work => [],
                  :Temp => [],
                  :AutoDeliverables => [],
                  :AutoMissingDeliverables => [ 'TestType/TestID2/0.5/TestDeliverable' ]
                }
              }, eval(iFile.read))
          end
        end
      end

    end

  end

end
