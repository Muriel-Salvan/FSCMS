#--
# Copyright (c) 2009-2011 Muriel Salvan (murielsalvan@users.sourceforge.net)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

module FSCMSTest

  module Actions

    class Build < ::Test::Unit::TestCase

      include FSCMSTest::Common

      # Test that a single deliverable builds correctly
      def testBuildSingleDeliverable
        setRepository('UniqueDeliverable') do
          runFSCMS(['Build', '--', '--target', 'TestType/TestID/0.1/TestDeliverable'])
        end
      end

    end

  end

end
