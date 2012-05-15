#!/usr/bin/env ruby

def run(command)
  puts command
  output = `#{command}`
  ret_val = $?.to_i
  if ret_val != 0 then
    puts output
    raise 'foo bar FIXME'
  else
    return output
  end
end

def git(subcommand)
  run("git --git-dir=\"#{DATABASE_GIT_DIR}\" --work-tree=\"#{DATABASE_DIR}\" #{subcommand}")
end

DATABASE_DIR = '/var/backups/calabacin'
DATABASE_FILENAME = 'pkg_list.txt'
DATABASE_PATH = File::join(DATABASE_DIR, DATABASE_FILENAME)
DATABASE_GIT_DIR = File::join(DATABASE_DIR, '.git/')
MAGIC_CMD = "dpkg --get-selections | awk '{print $1}' | sort > #{DATABASE_PATH}"
RUNAS_USER = 1001
RUNAS_GROUP = 1001
BRANCH_NAME = 'papion-dpkg'
UPSTREAM_REMOTE = 'git@github.com:pfigue/pkg_backup.git'

# puts DATABASE_DIR
# puts DATABASE_FILE
# # puts run("uname -abc")
# puts run(MAGIC_CMD)

def install()
=begin
run as root
=end
  # if not FileTest::directory?(DATABASE_DIR)
  Dir::mkdir(DATABASE_DIR, 0755)
  File.chown(RUNAS_USER, RUNAS_GROUP, DATABASE_DIR)
  # end
end

def init()
=begin
Initializes a new Git repo and a branch to store and version the package list
=end
  run("git init -q #{DATABASE_DIR}")
  run("touch #{DATABASE_PATH}")
  git("add #{DATABASE_FILENAME}")
  commit_description = 'Adds an empty list to initialize the repo'
  git("commit -m \"#{commit_description}\" #{DATABASE_FILENAME}")
  git("remote add upstream #{UPSTREAM_REMOTE}")
  git("checkout -b #{BRANCH_NAME}")
=begin
in the future we may have several branches in a repo
the checkout -b should be apart, for every branch
=end
end

def update()
=begin
Gets a new packages list and commits it
=end
  git("checkout #{BRANCH_NAME}")
  run(MAGIC_CMD)
  git("add #{DATABASE_PATH}")
  commit_description = 'FIXME blah blah'
  git("commit -m \"#{commit_description}\" #{DATABASE_PATH}")
  # this throws an exception when there is no changes and nothing to commit
end


def push()
  git("checkout #{BRANCH_NAME}")
  git("push upstream #{BRANCH_NAME}")
#FIXME it asks for ssh key!
end

=begin
logs
push changes (via githook?)
detect changes
crontab
argv parser
=end

# install()
# init() 
# update()
# push()
