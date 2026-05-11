# Get arf and REditorSupport extension to play nicely;
# This way we can see (in the REditorSupport extension window in VSCode) the
# R objects created in the arf terminal 
local({
  vscr_init <- file.path(
    Sys.getenv(if (.Platform$OS.type == "windows") "USERPROFILE" else "HOME"),
    ".vscode-R",
    "init.R"
  )
  if (file.exists(vscr_init)) source(vscr_init)
})
