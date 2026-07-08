# Run this ONCE from a Vivado batch session (Vivado and git must be in PATH):
#   vivado -mode batch -notrace -source add_git_buttons.tcl
#
# Registers two custom toolbar buttons in Vivado, same mechanism Hog uses
# for its own four buttons (application-wide, works with any project you
# later open, not just this one). Each button re-sources git_buttons.tcl
# and computes the repository path from whichever project is currently
# open, exactly like Hog's own Hog_check/Hog_listFiles/... buttons do.

remove_gui_custom_commands -quiet Hog_git_commit
create_gui_custom_command -name Hog_git_commit -description "Git: add -A + commit (asks for message in the Tcl Console)" -show_on_toolbar -command "set proj_file \[get_property DIRECTORY \[current_project\]\]; set index \[string last \"Projects/\" \$proj_file\]; set index \[expr \$index - 2\]; set repo_path \[string range \$proj_file 0 \$index\]; source \$repo_path/git_buttons.tcl; HogGitCommit \$repo_path"

remove_gui_custom_commands -quiet Hog_git_push
create_gui_custom_command -name Hog_git_push -description "Git: push current branch" -show_on_toolbar -command "set proj_file \[get_property DIRECTORY \[current_project\]\]; set index \[string last \"Projects/\" \$proj_file\]; set index \[expr \$index - 2\]; set repo_path \[string range \$proj_file 0 \$index\]; source \$repo_path/git_buttons.tcl; HogGitPush \$repo_path"

puts "Hog: custom 'Git Commit' / 'Git Push' buttons registered. Reopen Vivado's GUI if they don't show up immediately."
