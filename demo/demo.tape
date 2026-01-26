# Where should we write the GIF?
Output demo.gif

# Set up a 960x540 terminal with 24px font.
Set Shell bash
Set FontSize 20
Set Width 960
Set Height 540
Set Padding 0

# Type a command in the terminal.
Hide

Type 'NVIM_DEMO_CONFIG="$(pwd)/demo.lua"'
Enter
Type 'nvim() { command nvim -u "$NVIM_DEMO_CONFIG"; }'
Enter
Type 'clear'
Enter
Type "nvim"
Enter

Show

Sleep 1000ms

Type ":lua MiniPick.builtin.files()"
Sleep 500ms
Enter
Sleep 1000ms
Type "demo"
Sleep 1000ms
Down
Sleep 1000ms
Down

Sleep 2000ms

