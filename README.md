# RepoStatus

RepoStatus is a simple command line application for macOS to show the status of multiple local Git repositories. 
It indicates file have been modified, added, how many commits the remote is ahead or behind a remote, etc. 

Local repos can be added into named groups, useful if you have projects with multiple repos. 

### Usage

    USAGE: RepoStatus <subcommand>

    OPTIONS:
      --version               Show the version.
      -h, --help              Show help information.

    SUBCOMMANDS:
      status (default)        Display status for configured Git repos. Use --fetch
                              option to fetch from remotes first

                                  Repo name coloured as follows (priority order):
                                      red = Repo has modified files
                                      orange = Repo has added files
                                      yellow = Repo has untracked files
                                      green = Repo clean, no changes

                                  Repo status flags:
                                      + = Files added
                                      M = Files modified
                                      ? = New untracked files
                                      S = Has stashed changes
                                      ↑ = Ahead of remote
                                      ↓ = Behind remote
      config                  Print config file path
      key                     Display description of status flags
      addgroup                Add a new group to the collection
      addrepo                 Add a repo to a group within the collection
      removegroup             Remove group, and all contained repos
      removerepo              Remove a repo
      pull                    Performs a Git pull on all or specified repos, or all
                              repos in specified groups

### Examples:

Add groups, and repos to those groups, using the commands `addgroup` and `addrepo`

    RepoStatus addgroup "Super Project"
    
    RepoStatus addrepo /Users/bob/Source/SuperProject -g "Super Project" 
    RepoStatus addrepo /Users/bob/Source/SubProject -g "Super Project" 

Run command without parameters to show status of all groups/repos

    RepoStatus

Or, specify a group name to show status of only that group and its repos

    RepoStatus "Super Project"


### Screen shot:

![Example](./Documentation/example.png?raw=true)





