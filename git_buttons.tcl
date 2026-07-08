# Git commit/push helpers used by the "Git Commit" / "Git Push" custom
# Vivado GUI buttons (see add_git_buttons.tcl). This file is sourced fresh
# every time one of the two buttons is clicked, so it only needs to define
# the two procs below - no other side effect.

proc HogGitCommit {repo_path} {
  puts "Hog: type the commit message below and press Enter in this Tcl Console (empty message cancels)."
  flush stdout
  set msg [gets stdin]
  if {$msg eq ""} {
    puts "Hog: commit cancelled."
    return
  }
  set old_pwd [pwd]
  cd $repo_path
  if {[catch {exec -ignorestderr git add -A} add_res]} {
    puts "Hog: 'git add -A' failed:\n$add_res"
    cd $old_pwd
    return
  }
  if {[catch {exec -ignorestderr git commit -m $msg} commit_res]} {
    puts "Hog: 'git commit' failed (maybe there is nothing to commit?):\n$commit_res"
  } else {
    puts "Hog: commit done:\n$commit_res"
  }
  cd $old_pwd
}

proc HogGitPush {repo_path} {
  set old_pwd [pwd]
  cd $repo_path
  if {[catch {exec -ignorestderr git push} push_res]} {
    puts "Hog: 'git push' failed:\n$push_res"
  } else {
    puts "Hog: push done:\n$push_res"
  }
  cd $old_pwd
}
