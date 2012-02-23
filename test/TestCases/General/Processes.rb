#--
# Copyright (c) 2010 - 2012 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module FSCMSTest

  module General

    class Processes < ::Test::Unit::TestCase

      include FSCMSTest::Common

      # Test that processes defined in every directory are reachable
      def testProcessesReach
        setRepository('Processes') do |iRepoDir|
          runFSCMS(['Build', '--',
              '--target', 'TestType/TestID/0.1/TestDeliverableRoot',
              '--target', 'TestType/TestID/0.1/TestDeliverableType',
              '--target', 'TestType/TestID/0.1/TestDeliverableObject',
              '--target', 'TestType/TestID/0.1/TestDeliverableVersionedObject',
              '--target', 'TestType/TestID/0.1/TestDeliverableDeliverable',
            ])
          [
            'Root',
            'Type',
            'Object',
            'VersionedObject',
            'Deliverable'
          ].each do |iLevel|
            lBuiltFileName = "#{iRepoDir}/TestType/TestID/0.1/Deliverables/TestDeliverable#{iLevel}/BuiltFile"
            assert(File.exists?(lBuiltFileName))
            File.open(lBuiltFileName, 'r') do |iFile|
              assert_equal( [
                $FSCMSTest_RepositoryToolsDir,
                "#{iLevel}Process"
              ], iFile.read.split("\n"))
            end
          end
        end
      end

    end

  end

end
