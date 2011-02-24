{
  :Processes => {
    :DummyBuildObject => {
      :FullyAutomated => true,
      :Dir => $FSCMSTest_RepositoryToolsDir,
      :Cmd => 'ruby -w DummyBuild.rb @{DeliverableDir} ObjectProcess'
    }
  }
}