{
  :Processes => {
    :DummyBuild => {
      :FullyAutomated => true,
      :Dir => '@{Ref[TestType/TestID1/0.1/TestDeliverable]}',
      :Cmd => "ruby -w #{$FSCMSTest_RepositoryToolsDir}/DummyBuild.rb @{DeliverableDir}"
    }
  },
  :Deliverables => {
    'TestDeliverable' => {
      :Execute => {
        :Process => :DummyBuild
      }
    }
  }
}