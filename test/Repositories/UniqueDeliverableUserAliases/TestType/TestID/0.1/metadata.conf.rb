{
  :Aliases => {
    'VersionedObjectAlias' => 'VersionedObjectAliasValue'
  },
  :Deliverables => {
    'TestDeliverable' => {
      :Aliases => {
        'DeliverableAlias' => 'DeliverableAliasValue'
      },
      :Processes => {
        :DummyBuild => {
          :FullyAutomated => true,
          :Dir => $FSCMSTest_RepositoryToolsDir,
          :Cmd => 'ruby -w DummyBuild.rb @{DeliverableDir} @{RootAlias} @{TypeAlias} @{ObjectAlias} @{VersionedObjectAlias} @{DeliverableAlias}'
        }
      },
      :Execute => {
        :Process => :DummyBuild
      }
    }
  }
}