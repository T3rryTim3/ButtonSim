extends Node
## Manages global signals.
##
## I know this isnt proper gdscript name formatting but im to lazy to change it.
## Sorry.

@warning_ignore("unused_signal")
## Called on presitge
signal Prestige

@warning_ignore("unused_signal")
## Called when a prestige upgrade is bought
signal PrestigeUpgradeBought

@warning_ignore("unused_signal")
## Called when a crate is successfully opened
signal CrateOpened

@warning_ignore("unused_signal")
## Called when a crate is gained through any means.
signal CrateGained
