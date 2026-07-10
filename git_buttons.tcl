# Git commit/push helpers used by the "Git Commit" / "Git Push" custom
# Vivado GUI buttons (see add_git_buttons.tcl). This file is sourced fresh
# every time one of the two buttons is clicked, so it only needs to define
# the two procs below - no other side effect.
#
# Note: Vivado's Tcl console for custom GUI commands does not have Tk
# loaded (no toplevel/entry widgets available), and "gets stdin" does not
# work interactively there either. So instead of a Tk dialog, the commit
# message is collected by opening the message in Notepad (a plain native
# Windows app) and reading it back once the user saves and closes it.

proc HogAskCommitMessage {repo_path} {
  set msgfile [file join $repo_path .git HOG_COMMIT_EDITMSG.txt]
  set fp [open $msgfile w]
  puts $fp ""
  puts $fp "# Scrivi sopra il messaggio di commit."
  puts $fp "# Le righe che iniziano con # vengono ignorate."
  puts $fp "# Salva e chiudi Notepad per confermare il commit."
  puts $fp "# Lascia vuoto (o cancella tutto) e chiudi per annullare."
  close $fp

  puts "Hog: apro Notepad per il messaggio di commit - salva e chiudi la finestra per confermare..."
  flush stdout
  catch {exec notepad $msgfile}

  set fp [open $msgfile r]
  set content [read $fp]
  close $fp
  file delete -force $msgfile

  set msg_lines {}
  foreach line [split $content "\n"] {
    if {![string match "#*" $line]} {
      lappend msg_lines $line
    }
  }
  return [string trim [join $msg_lines "\n"]]
}

proc HogGitCommit {repo_path} {
  set msg [HogAskCommitMessage $repo_path]
  if {$msg eq ""} {
    puts "Hog: commit cancelled (empty message)."
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
