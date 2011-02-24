{
  :Deliverables => {
    'TestDeliverable' => {
      :Processes => {
        :DummyBuild => {
          :FullyAutomated => true,
          :Dir => $FSCMSTest_RepositoryToolsDir,
          :Cmd => 'ruby -w DummyBuild.rb @{DeliverableDir} @{SourceDir} @{DeliverableDir}'
        }
      },
      :Execute => {
        :Process => :DummyBuild
      }
    }
  }
}