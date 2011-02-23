{
  :Processes => {
    :DummyBuild => {
      :FullyAutomated => true,
      :Dir => $FSCMSTest_RepositoryToolsDir,
      :Cmd => 'ruby -w DummyBuild.rb @{DeliverableDir}'
    }
  },
  :Deliverables => {
    'TestDeliverable1' => {
      :Execute => {
        :Process => :DummyBuild
      }
    },
    'TestDeliverable2' => {
      :Execute => {
        :Process => :DummyBuild
      }
    }
  }
}