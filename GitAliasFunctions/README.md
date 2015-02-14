# GitAliasFunctions.psm1
A small PowerShell module defining aliases for git commands.

Git, of course, provides an alias mechanism via `git config`, 
but I'm extra lazy and think even `git co` is too many
characters to alias `git checkout`.
I could alias `git` as `g`, but `g co` is clumsy when I could
just type `gco`.  So I created this little module to alias
common git commands.
