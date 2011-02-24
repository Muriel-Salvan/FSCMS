{
  :Aliases => {
    'VersionedObjectAlias1' => 'VersionedObjectAlias1Value',
    'RootAlias3' => 'RootAlias3ValueVersionedObjectOverwrite',
    'TypeAlias2' => 'TypeAlias2ValueVersionedObjectOverwrite',
    'ObjectAlias1' => 'ObjectAlias1ValueVersionedObjectOverwrite',
    'RootAlias5' => 'RootAlias5ValueVersionedObjectOverwrite',
    'TypeAlias4' => 'TypeAlias4ValueVersionedObjectOverwrite',
    'ObjectAlias3' => 'ObjectAlias3ValueVersionedObjectOverwrite'
  },
  :Processes => {
    :DummyBuild => {
      :FullyAutomated => true,
      :Dir => $FSCMSTest_RepositoryToolsDir,
      :Cmd => 'ruby -w DummyBuild.rb @{DeliverableDir} @{RootAlias1} @{RootAlias2} @{RootAlias3} @{RootAlias4} @{RootAlias5} @{TypeAlias1} @{TypeAlias2} @{TypeAlias3} @{TypeAlias4} @{ObjectAlias1} @{ObjectAlias2} @{ObjectAlias3} @{VersionedObjectAlias1}'
    }
  },
  :Deliverables => {
    'TestDeliverable1' => {
      :Aliases => {
        'RootAlias4' => 'RootAlias4ValueDeliverable1Overwrite',
        'TypeAlias3' => 'TypeAlias3ValueDeliverable1Overwrite',
        'ObjectAlias2' => 'ObjectAlias2ValueDeliverable1Overwrite',
        'VersionedObjectAlias1' => 'VersionedObjectAlias1ValueDeliverable1Overwrite',
        'RootAlias5' => 'RootAlias5ValueDeliverable1Overwrite',
        'TypeAlias4' => 'TypeAlias4ValueDeliverable1Overwrite',
        'ObjectAlias3' => 'ObjectAlias3ValueDeliverable1Overwrite'
      },
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